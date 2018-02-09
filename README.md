# Backup Script for H2 DB in Docker

this script allows for an automated backup of a H2 database and automatically checks in the resulting SQL file in a Github repository of your choice. 

To do so, it uses the ```org.h2.tools.Script``` tool from the H2 driver to create a compressed SQL file with the complete database contents. Using the same tool, backups can be restored.

**To use this tool, the database needs to be online**
Creating an offline backup is only possible from the DB host, and the resulting file is not human readable.

## Running this script

### Using docker
This script depends on having access to the output file of the backup command. Since this zip file is created on the DB host, in a docker context simply letting the backup script container access a volume that is also used by the H2 container.

Keep in mind to change the environment variables accordingly to your setup.

```bash
docker run --rm --network moodle_moodle-net -v "$PWD":/usr/src/myapp -v <'location of mount for /data in h2 container'>:/data -e DB_HOST="h2-host" -e DB_PORT=1521 -e DB_USER="sa" -e DB_NAME="~/test" -e LOCATION="/data" -e GITHUB_USER="your username here" -e GITHUB_PASSWORD='your password here' -e GITHUB_ACCOUNT_OR_ORG='your username or org here' -e GITHUB_REPOSITORY='your repository name here' -w /usr/src/myapp openjdk:8 bash backup.sh
```

### Oldschool, in your own shell

Make sure you have Java installed first. You also need the command line tools ```unzip``` and ```git```

The script needs access to the DB server directory in which the backup zip will be created. If you can achieve this using ftp, sftp, sshfs or similar tools, you can use this script from a different host, otherwise you need to run this script on the same system that the db resides on.

 This script was created with Docker in mind, so you need to set the environment variables by hand:
```bash
DB_HOST="h2-host"
DB_PORT=1521
DB_USER="sa"
DB_NAME="~/test"
LOCATION="/data"
GITHUB_USER="your username here"
GITHUB_PASSWORD='your password here'
GITHUB_ACCOUNT_OR_ORG='your username or org here'
GITHUB_REPOSITORY='your repository name here'
```

Afterwards, you can simply run the script:
```bash
chmod +x backup.sh
./backup.sh
```

## Issues

If you run into any problems, feel free to create an issue and describe your problem.

If you find a fix for any problem that may occur to you, feel free to create a pull request.