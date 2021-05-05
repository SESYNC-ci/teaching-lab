## SESYNC Cyberinfrastructure Teaching-Lab

The National Socio-Environmental Synthesis Center ([www.sesync.org](https://www.sesync.org)) offers short courses on the use of cyberinfrastructure in pursuit of the Center's scientific mission. Software for the course is bundled into a series of Docker images, and relies on two GitHub repositories (this README information is located in both).

- This [source repository] on GitHub contains the Dockerfiles and additional data that provide instructions for a Docker daemon to build the images.

- The [handouts repository] on GitHub contains the data and worksheets used in the course, as well as user and group files with teaching lab log-in credentials for course participants.

[Releases] of the source on GitHub will reflect the date and name of a past training event. Trainees at a current or upcoming event should use the default (i.e. "latest") tag, unless otherwise instructed.

## Docker

This repository works in conjunction with the SESYNC-ci/handouts to provision a containerized, cloud platform providing software to participants during a workshop or short course.

- The [teaching-lab](https://github.com/sesync-ci/teaching-lab) and [handouts](https://github.com/SESYNC-ci/handouts.git) repositories must be cloned into your research-home space. 

- Create two text files with user and group information.  `users.txt` contains a username (**must be _all_ lowercase**) for each workshop participant, with each name on a separate line.  `groups.txt` contains a team name followed by team participants (space delimited), with each team on a separate line.  Save these files in `~/path/to/handouts/root/tmp/lab/` on your research-home space.  Note, these text files are in the `.gitignore` for the handouts repo. 

- Log in to docker01.research.sesync.org, and `cd` into the teaching-lab repository in your research-home space.  Your user will need to be in the `docker` UNIX group on this host.

  - Build the docker images defined by the Dockerfiles in the teaching-lab repo. Use `docker images` to see existing images, and `docker rmi <NAME>` and `docker image prune` to clean out existing images as needed before building.
    ```
    icarroll@docker01:teaching-lab$ make 
    ```

- Log into a host (eg. sshgw02.research.sesync.org) that can access `/nfs` and `cd` into the handouts repository in your research-home that you cloned earlier.  Run `make` to get the data. One side effect of running `make` in the handouts repository is the creation of a data.zip, whose contents need to be made available to the `docker-entrypoint.sh` script that initializes the docker containers. A second side effect is processing the root/tmp/lab/users.txt file if it exits.
    ```
    icarroll@sshgw02:handouts$ make
    ```

- Now, go back to the docker01 server, and type `cd /srv` to get to the built-in Linux folder called /srv.  Create a different clone of the handouts repo so the docker daemon will be able to mount folders within it.
If a handouts folder already exists, and therefore the clone fails, delete the handouts folder using 
`sudo rm -r handouts` before cloning.    
    ```
    icarroll@docker01:srv$ pwd
    /srv
    icarroll@docker01:srv$ sudo git clone https://github.com/SESYNC-ci/handouts.git
    ```

  - Unzip the data to that clone, so the docker daemon will be able to mount it.
    ```
    icarroll@docker01:srv$ cd handouts
    icarroll@docker01:/srv/handouts$ cp ~/path/to/handouts/data.zip /tmp
    icarroll@docker01:/srv/handouts$ sudo unzip /tmp/data.zip -d root/tmp/lab
    ```

  - Copy the user and group information to the same location
    ```
    icarroll@docker01:/srv/handouts$ cp ~/path/to/handouts/root/tmp/lab/*.txt /tmp
    icarroll@docker01:/srv/handouts$ sudo cp /tmp/*.txt root/tmp/lab/
    ```

  - Now start the lab
    ```
    icarroll@docker01:/srv/handouts$ make lab
    ```

- The lab is made with `docker stack deploy -c docker-compose.yml lab` command in the Makefile.  To stop the containers in the lab, use `docker stack rm docker-compose.yml lab`.  Only then you can remove and rebuild the containers if needed. 

- If you need to install R packages into the container while it is running (without taking it down and rebuilding it)
  
  - get the container ID
  ```
  icarroll@docker01:~$ docker container ls
  ```
  
  - go into the container you want to modify
  ```
  icarroll@docker01:~$ docker exec -ti -u root <CONTAINER ID> bash
  ```
  
  - execute R script to install packages
  ```
  icarroll@docker01:~$ Rscript -e "install.packages(c('<PACKAGE1>', '<PACKAGE2>'), lib = '/usr/lib/R/site-library')"
  ```

Why is this so complicated. Well, there are some gotcha's having to do with the SESYNC cyberinfrastrucutre:
- The docker server does not have access to /nfs.
- The docker container cannot mount to folders in  /nfs or /research-home, so the `make lab` target must be run from a clone of the repository in a local folder, e.g. /srv.

## Lab User Archives
Users may wish to have a copy of their lab files after the removal of the lab.

Run as yourself, substituting where needed:
```
icarroll@docker01:~$ sudo rsync -a /var/lib/docker/volumes/lab_home/_data/$USER/ /tmp/$USER-lab/  # note that the slash at the end of the path is significant
icarroll@docker01:~$ sudo chown -R icarroll /tmp/$USER-lab/
icarroll@docker01:~$ cd /tmp
icarroll@docker01:tmp$ zip -r -q ~/$USER-lab $USER-lab/
icarroll@docker01:tmp$ rm -rf /tmp/$USER-lab/  # cleanup temp files
```

At this point you will have a zip file in your research-home, but you should move the file to `/nfs/` so you can share with the user.    

Log into a host (eg. sshgw02.research.sesync.org) that can access `/nfs` and execute the following: 
```
icarroll@sshgw02:~$ mv $USER-lab.zip /nfs/icarroll-data
```

Go to [files.sesync.org](files.sesync.org) where you can obtain a sharing link to send to the user.    

After lab users have had time to request their files (usually a couple weeks after a training event), the data volumes can be removed to clean up the docker01 server.  
```
icarroll@docker01:~$ docker volume ls    # list the volumes
icarroll@docker01:~$ docker volume prune # remove the volumes
```

You now have a clean slate for the next training event.

[source repository]: https://github.com/SESYNC-ci/teaching-lab/
[handouts repository]: https://github.com/SESYNC-ci/handouts/
[Releases]: https://github.com/SESYNC-ci/teaching-lab/releases
[tags]: https://hub.docker.com/r/sesync/teaching-lab/tags/
