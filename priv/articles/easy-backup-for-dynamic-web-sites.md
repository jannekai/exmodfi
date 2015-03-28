For the last three years I've been maintaining the web server of Atkins ry, a non-profit association for the IT-students at HAAGA-HELIA University of Applied Sciences. It doesn't take much to set up a web server, but there are some issues to think about when the server is running on old donated hardware in the corner of the office.

When thinking about what is valuable at the server, the only thing is the source code for the web site and the content stored in the database. And last week I got a reminder why full backups are essential.

## Background information

I took upon the responsibility of maintaining the web server in the fall of 2004. At that point of time, the situation was not exactly normal. In the summer of 2004 a new building was built for the school and the offices of Atkins were moved. Unfortunately, the old web server "disappeared" during the move and was never found.

This wasn't really a big problem, because the old machine was just some random old computer and could be replaced easily. However, the bad thing was that there weren't any backups of the website found. In addition, the people who had created the web site weren't active anymore so finding some version of the website was somewhat hard. Luckily, an old development copy was found and the web site could be re-launched. However, it took about six months before the web site was fully back in business.

## When things go boom

To make sure that the problem with lost backups wouldn't happen while I was maintaining the site, I did setup a version control system using subversion on a separate server with full backups and raid disks.

However, last fall I was reminded that even if you have all the source code for the website available, it doesn't help if the stuff in the database is lost. Naturally I had done several backups manually, but when the hard drive broke, I lost a couple of week's worth of new posts and comments. Luckily installing Debian from scratch and setting the web server didn't take longer than one evening and nothing crucial was lost. Still, it reminded that manual backups are not really a long term solution.

## Making a script

The solution for the problem was to write a script to backup all of the website and database information and copy it to a remote server. The script I used is below (passwords and usernames hidden with ********):

    #!/bin/bash
    # Make a backup of the website and dump the database in
    # separate scripts for both create and insert statements.
    DATE=`date +'%Y-%m-%d'`
    NAME=backup-${DATE}

    # Create the backup dir if it doesn't exist
    if [ ! -e ~/backup ]
    then
        mkdir ~/backup
    fi

    # Check that the backup hasn't been run already today
    if [ -e ~/backup/${NAME} ]
    then
            echo "directory ~/backup/${NAME} exists"
            exit
    fi

    # Create the backup directory
    mkdir ~/backup/${NAME}

    # Copy the website to the backup dir
    cp -r ~/site ~/backup/${NAME}

    # Create a subdirectory for the sql dumps
    mkdir ~/backup/${NAME}/sql

    # Dump the database separately for create and insert statements
    CRE="mysqldump --no-create-db --no-data --add-drop-table"
    CRE="${CRE} --default-character-set=latin1 --create-options"
    CRE="${CRE} --user ****** --password=****** ****** "
    ${CRE} > ~/backup/${NAME}/sql/create.sql

    INS="mysqldump  --no-create-db --no-create-info --allow-keywords"
    INS="${INS} --default-character-set=latin1"
    INS="${INS} --user ****** --password=****** ****** "
    ${INS} > ~/backup/${NAME}/sql/insert.sql

    # Compress the backup and delete the directory
    tar -C ~/backup -czf ${NAME}.tgz ${NAME}
    rm -rf ~/backup/${NAME}

    # Copy the backup using scp
    scp ~/backup/${NAME}.tgz ******@server.fi:backup/

Even if the above script makes the backup process easy and removes the possibility to make manual errors, it doesn't solve the problem of
automating the task. Luckily we have crontab, which is made for situations like this. I decided to run the backup every Monday evening and
the following crontab script allowed me to do it:

    # Crontab script to run the weekly-backup script
    # every Monday at 22:00
    0 22 * * 1 $HOME/bin/weekly-backup.sh &> /dev/null

## Is everything perfect?

The above script and crontab are really just the absolute minimum you should have for backing up a website with dynamic content.
The biggest problem with the above setup is that it doesn't notify in case of a failure. Therefore the backups should be checked
every now and then to make sure they can be used for restoring the site.

Furthermore, the above is really suitable for situation when nothing crucial is lost and money is tight. The first thing I would
do to improve the situation would be to use a hosting service which has a real infrastructure for maintaining backups and procedures
for hardware failures.
