# Linux Administration cheatsheet

## User Management

### View/List Users

```bash
# Show current username
whoami

# Show current user ID
id -u

# Show detailed user info
id
id username

# List all users
cat /etc/passwd

# List only usernames
cut -d: -f1 /etc/passwd
getent passwd | cut -d: -f1

# Count total users
cat /etc/passwd | wc -l
```

### Create Users

```bash
# Create new user
sudo useradd username

# Create user with home directory
sudo useradd -m username

# Create user with specific shell
sudo useradd -s /bin/bash username

# Create user with home directory
sudo useradd -m username 

# Set password
sudo passwd username

# Create system user
sudo useradd -r username
```

### Delete Users

```bash
# Delete user (keep home directory)
sudo userdel username

# Delete user and home directory
sudo userdel -r username

# Delete user and all files
sudo userdel -rf username
```

### Modify Users

```bash
# Change user password
sudo passwd username

# Change current user password
passwd

# Lock user account
sudo usermod -L username

# Unlock user account
sudo usermod -U username

# Change user's login name
sudo usermod -l newname oldname

# Change user's home directory
sudo usermod -d /new/home -m username

# Change user's shell
sudo usermod -s /bin/zsh username

# Set account expiration date
sudo usermod -e YYYY-MM-DD username
```

### Switch User

```bash
# Switch to another user
su - username

# Switch to root
sudo su -
su -

# Run single command as another user
sudo -u username command
```

## Group Management

### View/List Groups

```bash
# List all groups
cat /etc/group

# List only group names
cut -d: -f1 /etc/group
getent group | cut -d: -f1

# List groups for a user
groups username

# List groups for current user
groups

# List groups with detailed info
id username
id -G username        # Group IDs only
id -Gn username       # Group names only

# View members of a specific group
getent group groupname
grep '^groupname:' /etc/group
```

### Create Groups

```bash
# Create new group
sudo groupadd groupname

# Create group with specific GID
sudo groupadd -g 1500 groupname

# Create system group
sudo groupadd -r groupname
```

### Delete Groups

```bash
# Delete group
sudo groupdel groupname
```

### Manage Group Membership

```bash
# Add user to a group (append)
sudo usermod -aG groupname username

# Add user to multiple groups
sudo usermod -aG group1,group2,group3 username

# Change user's primary group
sudo usermod -g groupname username

# Remove user from a group
sudo gpasswd -d username groupname
sudo usermod -rG groupname username
sudo deluser username groupname    # Debian/Ubuntu

# Set user's supplementary groups (replaces all)
sudo usermod -G group1,group2,group3 username

# Add user to group directly
sudo gpasswd -a username groupname

# Set group administrators
sudo gpasswd -A admin1,admin2 groupname
```

## File Permissions

### View Permissions

```bash
# View file permissions
ls -l filename

# View directory permissions
ls -ld directory/

# View permissions in numeric format
stat -c '%a %n' filename

# View detailed file info
stat filename

# View ACL permissions
getfacl filename
```

### Change Permissions (Symbolic)

```bash
# Add permissions
chmod u+x filename          # Add execute for owner
chmod g+w filename          # Add write for group
chmod o+r filename          # Add read for others
chmod a+x filename          # Add execute for all

# Remove permissions
chmod u-x filename          # Remove execute from owner
chmod g-w filename          # Remove write from group
chmod o-r filename          # Remove read from others
chmod a-x filename          # Remove execute from all

# Set exact permissions
chmod u=rwx filename        # Owner: rwx only
chmod g=rx filename         # Group: rx only
chmod o=r filename          # Others: r only
chmod u=rwx,g=rx,o=r filename  # Set all at once

# Recursive changes
chmod -R u+x directory/
```

### Change Permissions (Numeric)

```bash
# Common permission patterns
chmod 755 filename          # rwxr-xr-x (scripts, executables)
chmod 644 filename          # rw-r--r-- (regular files)
chmod 600 filename          # rw------- (private files)
chmod 700 filename          # rwx------ (private executables)
chmod 777 filename          # rwxrwxrwx (all permissions - avoid!)
chmod 444 filename          # r--r--r-- (read-only for all)

# Recursive changes
chmod -R 755 directory/

# Permission values:
# r (read)    = 4
# w (write)   = 2
# x (execute) = 1
# Sum values: rwx=7, rw=6, rx=5, r=4
```

### Change Ownership

```bash
# Change file owner
sudo chown newowner filename

# Change owner and group
sudo chown newowner:newgroup filename

# Change owner recursively
sudo chown -R newowner directory/

# Change group only
sudo chgrp newgroup filename
sudo chgrp -R newgroup directory/

# Change to current user
sudo chown $USER filename

# Change to current user and group
sudo chown $USER:$USER filename
```

### Special Permissions

```bash
# Setuid (run as file owner)
chmod u+s filename
chmod 4755 filename

# Setgid (run as file group, inherit group in directory)
chmod g+s filename
chmod 2755 filename

# Sticky bit (only owner can delete in directory)
chmod +t directory/
chmod 1755 directory/

# Combine special permissions
chmod 6755 filename         # setuid + setgid
chmod 7755 directory/       # all special permissions

# View special permissions in ls output:
# s in user position = setuid
# s in group position = setgid
# t in others position = sticky bit
# S or T (capital) = permission bit not set
```

### Default Permissions (umask)

```bash
# View current umask
umask

# View umask in symbolic form
umask -S

# Set umask (subtracted from default)
umask 022    # Files: 644, Directories: 755
umask 027    # Files: 640, Directories: 750
umask 077    # Files: 600, Directories: 700 (private)

# Make umask permanent (add to ~/.bashrc)
echo "umask 022" >> ~/.bashrc

# Default base permissions:
# Files: 666 (rw-rw-rw-)
# Directories: 777 (rwxrwxrwx)
# Actual permissions = Default - umask
```

### Access Control Lists (ACL)

```bash
# View ACL permissions
getfacl filename

# Add ACL for specific user
setfacl -m u:username:rwx filename

# Add ACL for specific group
setfacl -m g:groupname:rx filename

# Add multiple ACL entries
setfacl -m u:user1:rw,u:user2:r filename

# Remove ACL for user
setfacl -x u:username filename

# Remove ACL for group
setfacl -x g:groupname filename

# Remove all ACLs
setfacl -b filename

# Set default ACL for directory (inherited by new files)
setfacl -d -m u:username:rwx directory/

# Apply ACLs recursively
setfacl -R -m u:username:rwx directory/

# Copy ACLs from one file to another
getfacl file1 | setfacl --set-file=- file2

# Backup and restore ACLs
getfacl -R directory/ > acl_backup.txt
setfacl --restore=acl_backup.txt
```

## Permission Reference

### Numeric Permission Patterns

```
777 = rwxrwxrwx (all permissions for everyone - avoid!)
755 = rwxr-xr-x (owner: full, others: read+execute) - scripts
644 = rw-r--r-- (owner: read+write, others: read) - files
700 = rwx------ (owner: full, others: none) - private scripts
600 = rw------- (owner: read+write, others: none) - private files
555 = r-xr-xr-x (read+execute for all, no write)
444 = r--r--r-- (read-only for all)
```

### Special Permissions

```
4000 = Setuid (4xxx)
2000 = Setgid (2xxx)
1000 = Sticky bit (1xxx)

4755 = rwsr-xr-x (setuid + 755)
2755 = rwxr-sr-x (setgid + 755)
1755 = rwxr-xr-t (sticky + 755)
6755 = rwsr-sr-x (setuid + setgid + 755)
```

### Symbolic Notation

```
u = user/owner
g = group
o = others
a = all

+ = add permission
- = remove permission
= = set exact permission

r = read (4)
w = write (2)
x = execute (1)
```
