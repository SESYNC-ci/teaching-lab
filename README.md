## SESYNC Cyberinfrastructure Teaching-Lab

The National Socio-Environmental Synthesis Center ([www.sesync.org](https://www.sesync.org)) offers short courses on the use of cyberinfrastructure in pursuit of the Center's scientific mission. Software for the course is bundled into a Docker image, accessible in two locations (this README serves both).

- The [source repository] on GitHub contains the Dockerfile and additional data that provide instructions for a Docker daemon to build an image.

- The [image repository] on Docker Hub contains automated builds of the teaching-lab image.

[Releases] of the source on GitHub will be matched with [tags] on Docker Hub images, reflecting the date and name of a past training event. Trainees at a current or upcoming event should use the defaul (i.e. "latest") tag, unless otherwise instructed.

### Users and Volumes

Create a user by setting the USER environment variable (under the "Settings" tab in Kitematic). The password will be the same as the username. A folder on the host may be mounted as volume "/data" in the container. Note that doing so requires starting a new container. From the Kitematic "Settings" tab for the current container, select "Volumes" and click "CHANGE" in the row for "/data". Choose, or create, a folder, in your filesystem.

[source repository]: https://github.com/SESYNC-ci/teaching-lab/
[image repository]: https://hub.docker.com/r/sesync/teaching-lab/
[Releases]: https://github.com/SESYNC-ci/teaching-lab/releases
[tags]: https://hub.docker.com/r/sesync/teaching-lab/tags/
