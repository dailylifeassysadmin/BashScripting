# How to Use  _chmod_  Without  _/usr/bin/chmod_

## 1. Overview[](https://www.baeldung.com/linux/use-chmod-without-usr-bin-chmod#overview)

The  [_chmod_](https://www.baeldung.com/linux/chown-chmod-permissions#chmod)  command in Linux allows users to modify the permissions of files and directories. It’s typically accessed through the  _/usr/bin/chmod_  file path. However, it’s possible to set file permissions without using the  _chmod_  command. This might be necessary when the execute permissions of  _/usr/bin/chmod_  have been corrupted for some reason.

In this tutorial, we’ll learn different approaches for restoring the execute permissions of the  _/usr/bin/chmod_  file in case they were mistakenly removed. Further, we’ll discuss how to do so without having to reinstall any binaries or  [GNU Coreutils](https://www.gnu.org/software/coreutils/).

## 2. Reproducing the Problem[](https://www.baeldung.com/linux/use-chmod-without-usr-bin-chmod#reproducing-the-problem)

We can use  [_which_](https://www.baeldung.com/linux/get-path-of-linux-command#which-command)  to locate the file path of the  _chmod_  command:

```bash
$ which chmod
/usr/bin/chmod
```

We see that  **_chmod_  refers to the binary executable file  _/usr/bin/chmod_**.

If we list the file in a long format using  [_ls_](https://www.baeldung.com/linux/list-one-filename-per-line)  with the  _-l_  option, we see that the execute permissions are set for the owning user, group, and others:

```bash
$ ls -l /usr/bin/chmod
-rwxr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

Now, let’s suppose that we’ve carelessly used  [_sudo_](https://www.baeldung.com/linux/sudo-command)  with  _chmod_  to remove the execute permissions of the  _/usr/bin/chmod_  command itself:

```bash
$ sudo chmod 444 /usr/bin/chmod
[sudo] password for sysadmin: 
$ ls -l /usr/bin/chmod
-r--r--r-- 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

When using the  _chmod_  command with the  _444_  option in  [octal notation](https://www.baeldung.com/linux/chown-chmod-permissions#octal), we grant read-only permission to the owning user, group, and others.

Let’s now create an empty file called  _script.sh_  and try to make it executable using  _chmod_:

```bash
$ touch script.sh
$ ls -l script.sh
-rw-r--r-- 1 sysadmin sysadmin 0 May 12 16:08 script.sh
$ chmod +x script.sh
bash: /usr/bin/chmod: Permission denied
```

First,  **we see that the newly created  _script.sh_  file has  _644_  (_rw-r–r–_) as octal permissions**. This is because the default  _[umask](https://www.baeldung.com/linux/change-folder-and-content-permissions#2-default-access-permission)_  is  _0022_, i.e., no write permissions are given to the owning group and others. By default, new files have octal permissions set to  _666_, and the  _umask_  defines which permissions should be further removed.

After that, when we try to use the  _chmod_  command over  _script.sh_  to enable execution, we get an error. Of course, that results from the fact that  **the  _chmod_  command is itself no longer executable**.

It’s important to note that  _/bin/chmod_  and  _/usr/bin/chmod_  are usually  [hard-linked](https://www.baeldung.com/linux/symbolic-and-hard-links#hard-links), meaning they both have the same  [inode](https://www.baeldung.com/linux/inodes)  number:

```bash
$ ls -li /bin/chmod /usr/bin/chmod
33555957 -r--r--r-- 1 root root 64288 Feb 28  2019 /bin/chmod
33555957 -r--r--r-- 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

The  _-i_  option used with  _ls_  displays the inode number of each file. In this case, both files have the same inode number of  _33555957_. Therefore, changing the content or permissions of one file also changes the other.

To correct the broken permissions for  _chmod_, we can use several methods. Let’s go over some of them.

## 3. Using the Dynamic Loader[](https://www.baeldung.com/linux/use-chmod-without-usr-bin-chmod#using-the-dynamic-loader)

The  [dynamic loader](https://www.baeldung.com/cs/dynamic-linking-vs-dynamic-loading#loading)  in Linux is responsible for loading an executable and linking the necessary shared libraries. For instance, on a 64-bit Debian OS, we can find the loader at  _/lib64/ld-linux-x86-64.so.2_.

By using the dynamic loader, we can load  _/usr/bin/chmod_  while also specifying the permissions it should grant:

```bash
$ sudo /lib64/ld-linux-x86-64.so.2 /usr/bin/chmod +x /usr/bin/chmod
$ ls -l /usr/bin/chmod
-r-xr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

Here,  **we’ve used the dynamic loader to run the  _chmod_  command as an executable and grant itself execute permissions via the  _+x_  option**.

## 4. Using  _cp_[](https://www.baeldung.com/linux/use-chmod-without-usr-bin-chmod#using-cp)

**Another method for restoring the execute permissions of  _/usr/bin/chmod_  is to use  [_cp_](https://linux.die.net/man/1/cp)  to create a new executable file**. We can do so in two steps:

1.  copy both the content and the permissions of an already executable file like  _/usr/bin/ls_  into a temporary file named  _chmod_new_
2.  copy only the content of the  _/usr/bin/chmod_  file into  _chmod_new_

By doing so,  _chmod_new_  inherits its permissions from the executable  _/usr/bin/ls_, while its content comes from  _/usr/bin/chmod_. In this way,  _chmod_new_  becomes a fully functional executable  _chmod_  command:

```bash
$ cp /usr/bin/ls chmod_new
$ cp /usr/bin/chmod chmod_new
$ ls -l chmod_new
-rwxr-xr-x 1 sysadmin sysadmin 64288 May 12 16:14 chmod_new
$ sudo ./chmod_new +x /usr/bin/chmod
$ ls -l /usr/bin/chmod
-r-xr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

By using  _chmod_new_, we can successfully restore the execution bits of  _/usr/bin/chmod_. Essentially, apart from their owner, both files are now equivalent  _chmod_  commands. **This method works because  _cp_  only copies the file content but not the permissions when the destination file already exists**.

It’s important to note that if the destination file doesn’t exist,  _cp_  copies the file permissions of the source file or the default ones as determined by the  _umask_, depending on which of the two is more restrictive.

## 5. Using  _install_[](https://www.baeldung.com/linux/use-chmod-without-usr-bin-chmod#using-install)

Another way to restore  _/usr/bin/chmod_  into an executable file is via the  [_install_](https://www.baeldung.com/linux/install-command)  command which is part of the GNU Coreutils package.  **This command functions similarly to  _cp_  as it can copy files, but it can also set the required permissions using the  _-m_  option**:

```bash
$ install -m +rwx /usr/bin/chmod chmod_new
$ ls -l chmod_new
-rwxrwxrwx 1 sysadmin sysadmin 64288 May 12 16:17 chmod_new
$ sudo ./chmod_new +x /usr/bin/chmod
$ ls -l /usr/bin/chmod
-r-xr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

The  _install_  command copies the content of  _/usr/bin/chmod_  to a file called  _chmod_new_  and sets the latter’s permissions to allow read, write, and execute access for all users.

## 6. Using  _rsync_[](https://www.baeldung.com/linux/use-chmod-without-usr-bin-chmod#using-rsync)

Alternatively,  **[_rsync_](https://www.baeldung.com/linux/rsync-transfer-files)  also allows setting file permissions for copied files**:

```bash
$ rsync --chmod=ugo+x /usr/bin/chmod chmod_new
$ ls -l chmod_new
-r-xr-xr-x 1 sysadmin sysadmin 64288 May 12 16:19 chmod_new
$ sudo ./chmod_new +x /usr/bin/chmod
$ ls -l /usr/bin/chmod
-r-xr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

Here, we use the  _–chmod_  option to grant execute permissions for all users to the newly created  _chmod_new_  file. Then, we can use this file to restore execute permissions on  _/usr/bin/chmod_.

## 7. Using  _tar_[](https://www.baeldung.com/linux/use-chmod-without-usr-bin-chmod#using-tar)

Another approach is to use  [_tar_](https://www.baeldung.com/linux/tar-command), which stands for  _tape archive(r)_.  **The command allows setting file permissions via the  _–mode_  option when creating the archive**:

```bash
$ tar --mode 0755 -cf chmod.tar /usr/bin/chmod
tar: Removing leading `/' from member names
```

In this method, the  _tar_  command sets the octal permissions  _0755_  to the file being archived. We use the  _-c_  option to create the archive, while the  _-f_  option specifies the archive file name as  _chmod.tar_.

To extract the contents of the archive, we use the  _tar_  command with the  _xvf_  options, where  _–__x_  extracts the archive,  _–__v_  gives verbose output, and  _–__f_  specifies the archive file name:

```bash
$ tar -xvf chmod.tar
usr/bin/chmod
$ ls -l usr/bin/chmod
-rwxr-xr-x 1 sysadmin sysadmin 64288 Feb 28  2019 usr/bin/chmod
$ sudo usr/bin/chmod +x /usr/bin/chmod
$ ls -l /usr/bin/chmod
-r-xr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

Alternatively, we can combine the two commands on a single line without creating an intermediate archive file:

```bash
$ tar --mode 0755 -cf - /usr/bin/chmod | tar xvf -
tar: Removing leading `/' from member names
usr/bin/chmod
```

We can achieve this by piping the output of the archive creation command to the extraction command via  [_stdin_](https://www.baeldung.com/linux/stream-redirections#redirect-input)  using the  _–_  symbol as the archive file name. The  [leading slashes warning](https://www.baeldung.com/linux/tar-absolute-paths-and-removing-leading-slashes)  is important, as we don’t want to overwrite the original _chmod_  before making sure everything is as expected.

## 8. Using Interpreters[](https://www.baeldung.com/linux/use-chmod-without-usr-bin-chmod#using-interpreters)

**We can also use the  _chmod_  facilities of programming languages such as  [Perl](https://www.baeldung.com/linux/portable-command-file-size#1-perl)  and  [Python](https://www.baeldung.com/linux/portable-command-file-size#2-python)**.

For example, we can use Perl’s  _chmod_  with octal permissions  _0755_  over the  _/usr/bin/chmod_  file:

```bash
$ sudo perl -e 'chmod 0755, "/usr/bin/chmod"'
$ ls -l /usr/bin/chmod
-rwxr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

The  _-e_  option allows executing a given command specified here within single quotes.

Similarly, in Python, we can begin by importing the  _os_  library and then use its  _os.chmod()_  method to set the permissions:

```bash
$ sudo python3 -c 'import os; os.chmod("/usr/bin/chmod", 0o755)'
$ ls -l /usr/bin/chmod
-rwxr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

Here, we need to use the  _0o_  prefix when specifying an octal literal.

## 9. Using Vim[](https://www.baeldung.com/linux/use-chmod-without-usr-bin-chmod#using-vim)

Finally,  **we can use the  [Vim](https://www.baeldung.com/linux/vi-vim-editors)  text editor to change the permissions of  _/usr/bin/chmod_  with a single command**:

```bash
$ sudo vim -c "call setfperm('/usr/bin/chmod', 'rwxr-xr-x') | quit"
$ ls -l /usr/bin/chmod
-rwxr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
```

The  _-c_  option allows for executing an  [_ex_](https://www.baeldung.com/linux/vi-editor#3-ex-mode)  command in Vim. In this case, we call the  [_setfperm()_](https://vimhelp.org/builtin.txt.html#setfperm%28%29)  function which can change file permissions, and we pass it the required file name and permissions as arguments.

By changing its permissions to  _rwxr-xr-x_  the file becomes world-executable again.

## 10. Conclusion[](https://www.baeldung.com/linux/use-chmod-without-usr-bin-chmod#10-conclusion)

In this article, we’ve seen several methods for restoring the executable status of the  _chmod_  command without relying on  _/usr/bin/chmod_. The workarounds include the use of the dynamic loader,  _cp_,  _install_,  _rsync_,  _tar_, Perl, Python, and Vim.

By employing these workarounds, we can restore the functionality of the  _chmod_  command and perform necessary file permission changes.
