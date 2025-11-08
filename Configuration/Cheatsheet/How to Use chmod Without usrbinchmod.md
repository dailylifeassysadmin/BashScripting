How to Use chmod Without /usr/bin/chmod

freestar
Last updated: March 18, 2024


Written by:Jimmy Azar

Reviewed by:Hiks Gerganov
AdministrationFile Permissionschmod cp install tar vim
1. Overview
The chmod command in Linux allows users to modify the permissions of files and directories. It’s typically accessed through the /usr/bin/chmod file path. However, it’s possible to set file permissions without using the chmod command. This might be necessary when the execute permissions of /usr/bin/chmod have been corrupted for some reason.

In this tutorial, we’ll learn different approaches for restoring the execute permissions of the /usr/bin/chmod file in case they were mistakenly removed. Further, we’ll discuss how to do so without having to reinstall any binaries or GNU Coreutils.

2. Reproducing the Problem
We can use which to locate the file path of the chmod command:

$ which chmod
/usr/bin/chmod
Copy
We see that chmod refers to the binary executable file /usr/bin/chmod.

If we list the file in a long format using ls with the -l option, we see that the execute permissions are set for the owning user, group, and others:


freestar
$ ls -l /usr/bin/chmod
-rwxr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
Now, let’s suppose that we’ve carelessly used sudo with chmod to remove the execute permissions of the /usr/bin/chmod command itself:

$ sudo chmod 444 /usr/bin/chmod
[sudo] password for sysadmin: 
$ ls -l /usr/bin/chmod
-r--r--r-- 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
When using the chmod command with the 444 option in octal notation, we grant read-only permission to the owning user, group, and others.

Let’s now create an empty file called script.sh and try to make it executable using chmod:

$ touch script.sh
$ ls -l script.sh
-rw-r--r-- 1 sysadmin sysadmin 0 May 12 16:08 script.sh
$ chmod +x script.sh
bash: /usr/bin/chmod: Permission denied
Copy
First, we see that the newly created script.sh file has 644 (rw-r–r–) as octal permissions. This is because the default umask is 0022, i.e., no write permissions are given to the owning group and others. By default, new files have octal permissions set to 666, and the umask defines which permissions should be further removed.

After that, when we try to use the chmod command over script.sh to enable execution, we get an error. Of course, that results from the fact that the chmod command is itself no longer executable.


freestar
It’s important to note that /bin/chmod and /usr/bin/chmod are usually hard-linked, meaning they both have the same inode number:

$ ls -li /bin/chmod /usr/bin/chmod
33555957 -r--r--r-- 1 root root 64288 Feb 28  2019 /bin/chmod
33555957 -r--r--r-- 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
The -i option used with ls displays the inode number of each file. In this case, both files have the same inode number of 33555957. Therefore, changing the content or permissions of one file also changes the other.

To correct the broken permissions for chmod, we can use several methods. Let’s go over some of them.

3. Using the Dynamic Loader
The dynamic loader in Linux is responsible for loading an executable and linking the necessary shared libraries. For instance, on a 64-bit Debian OS, we can find the loader at /lib64/ld-linux-x86-64.so.2.

By using the dynamic loader, we can load /usr/bin/chmod while also specifying the permissions it should grant:

freestar
$ sudo /lib64/ld-linux-x86-64.so.2 /usr/bin/chmod +x /usr/bin/chmod
$ ls -l /usr/bin/chmod
-r-xr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
Here, we’ve used the dynamic loader to run the chmod command as an executable and grant itself execute permissions via the +x option.

4. Using cp
Another method for restoring the execute permissions of /usr/bin/chmod is to use cp to create a new executable file. We can do so in two steps:

copy both the content and the permissions of an already executable file like /usr/bin/ls into a temporary file named chmod_new
copy only the content of the /usr/bin/chmod file into chmod_new
By doing so, chmod_new inherits its permissions from the executable /usr/bin/ls, while its content comes from /usr/bin/chmod. In this way, chmod_new becomes a fully functional executable chmod command:

$ cp /usr/bin/ls chmod_new
$ cp /usr/bin/chmod chmod_new
$ ls -l chmod_new
-rwxr-xr-x 1 sysadmin sysadmin 64288 May 12 16:14 chmod_new
$ sudo ./chmod_new +x /usr/bin/chmod
$ ls -l /usr/bin/chmod
-r-xr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
By using chmod_new, we can successfully restore the execution bits of /usr/bin/chmod. Essentially, apart from their owner, both files are now equivalent chmod commands. This method works because cp only copies the file content but not the permissions when the destination file already exists.

It’s important to note that if the destination file doesn’t exist, cp copies the file permissions of the source file or the default ones as determined by the umask, depending on which of the two is more restrictive.

5. Using install
Another way to restore /usr/bin/chmod into an executable file is via the install command which is part of the GNU Coreutils package. This command functions similarly to cp as it can copy files, but it can also set the required permissions using the -m option:

$ install -m +rwx /usr/bin/chmod chmod_new
$ ls -l chmod_new
-rwxrwxrwx 1 sysadmin sysadmin 64288 May 12 16:17 chmod_new
$ sudo ./chmod_new +x /usr/bin/chmod
$ ls -l /usr/bin/chmod
-r-xr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
The install command copies the content of /usr/bin/chmod to a file called chmod_new and sets the latter’s permissions to allow read, write, and execute access for all users.

6. Using rsync
Alternatively, rsync also allows setting file permissions for copied files:


freestar
$ rsync --chmod=ugo+x /usr/bin/chmod chmod_new
$ ls -l chmod_new
-r-xr-xr-x 1 sysadmin sysadmin 64288 May 12 16:19 chmod_new
$ sudo ./chmod_new +x /usr/bin/chmod
$ ls -l /usr/bin/chmod
-r-xr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
Here, we use the –chmod option to grant execute permissions for all users to the newly created chmod_new file. Then, we can use this file to restore execute permissions on /usr/bin/chmod.

7. Using tar
Another approach is to use tar, which stands for tape archive(r). The command allows setting file permissions via the –mode option when creating the archive:

$ tar --mode 0755 -cf chmod.tar /usr/bin/chmod
tar: Removing leading `/' from member names
Copy
In this method, the tar command sets the octal permissions 0755 to the file being archived. We use the -c option to create the archive, while the -f option specifies the archive file name as chmod.tar.

To extract the contents of the archive, we use the tar command with the xvf options, where –x extracts the archive, –v gives verbose output, and –f specifies the archive file name:

$ tar -xvf chmod.tar
usr/bin/chmod
$ ls -l usr/bin/chmod
-rwxr-xr-x 1 sysadmin sysadmin 64288 Feb 28  2019 usr/bin/chmod
$ sudo usr/bin/chmod +x /usr/bin/chmod
$ ls -l /usr/bin/chmod
-r-xr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
Alternatively, we can combine the two commands on a single line without creating an intermediate archive file:

$ tar --mode 0755 -cf - /usr/bin/chmod | tar xvf -
tar: Removing leading `/' from member names
usr/bin/chmod
Copy
We can achieve this by piping the output of the archive creation command to the extraction command via stdin using the – symbol as the archive file name. The leading slashes warning is important, as we don’t want to overwrite the original chmod before making sure everything is as expected.

8. Using Interpreters
We can also use the chmod facilities of programming languages such as Perl and Python.

For example, we can use Perl’s chmod with octal permissions 0755 over the /usr/bin/chmod file:


freestar
$ sudo perl -e 'chmod 0755, "/usr/bin/chmod"'
$ ls -l /usr/bin/chmod
-rwxr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
The -e option allows executing a given command specified here within single quotes.

Similarly, in Python, we can begin by importing the os library and then use its os.chmod() method to set the permissions:

$ sudo python3 -c 'import os; os.chmod("/usr/bin/chmod", 0o755)'
$ ls -l /usr/bin/chmod
-rwxr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
Here, we need to use the 0o prefix when specifying an octal literal.

9. Using Vim
Finally, we can use the Vim text editor to change the permissions of /usr/bin/chmod with a single command:

$ sudo vim -c "call setfperm('/usr/bin/chmod', 'rwxr-xr-x') | quit"
$ ls -l /usr/bin/chmod
-rwxr-xr-x 1 root root 64288 Feb 28  2019 /usr/bin/chmod
Copy
The -c option allows for executing an ex command in Vim. In this case, we call the setfperm() function which can change file permissions, and we pass it the required file name and permissions as arguments.

By changing its permissions to rwxr-xr-x the file becomes world-executable again.

10. Conclusion
In this article, we’ve seen several methods for restoring the executable status of the chmod command without relying on /usr/bin/chmod. The workarounds include the use of the dynamic loader, cp, install, rsync, tar, Perl, Python, and Vim.

By employing these workarounds, we can restore the functionality of the chmod command and perform necessary file permission changes.