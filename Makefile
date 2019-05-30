ORG = sesync
IMAGES = lab-rstudio lab-jupyter lab-debian  
.PHONY: clean push $(IMAGES)
build: $(IMAGES)
$(IMAGES):
	docker build -t $(ORG)/$@ ./$@
clean:
	docker rmi $(addprefix $(ORG)/, $(IMAGES))
push:

lab-rstudio lab-jupyter: lab-debian

# # TODO / IDEAS
# - images should be pushed to a registry (e.g. dockerhub)
