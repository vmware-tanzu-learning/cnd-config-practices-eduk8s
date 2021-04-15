NAME                  = cnd-config-practices
IMAGE_SOURCE		  = https://github.com/platform-acceleration-lab/cnd-config-practices-eduk8s
CONTAINER_REGISTRY    = ghcr.io/platform-acceleration-lab
CONTAINER_REPOSITORY  = ${NAME}
version               = latest

# Put it first so that "make" without argument is like "make help".
run: build kind-start educates-deploy

reload: build educates-deploy educates-refresh

refresh: build educates-refresh

.PHONY: build kind-start kind-stop educates-deploy educates-refresh release deploy get-reporeg get-name

kind-start:
	deploy/environment/kind/start.sh ${NAME}

kind-stop:
	deploy/environment/kind/stop.sh ${NAME}

educates-deploy:
	deploy/platform/educates/deploy.sh installEducates ${NAME}
	deploy/platform/educates/deploy.sh loadWorkshop ${NAME}
	deploy/platform/educates/deploy.sh loadContent ${NAME}

educates-refresh:
	deploy/platform/educates/deploy.sh loadContent ${NAME}

build:
	docker build --build-arg IMAGE_SOURCE=${IMAGE_SOURCE} \
				 -t ${CONTAINER_REPOSITORY}:${version} \
				 -t ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${version} .
	rm -rf build
	mkdir -p build
	docker create --name ${NAME}-build ${CONTAINER_REPOSITORY}:${version}
	docker cp ${NAME}-build:/usr/share/nginx/html/. build/
	docker rm ${NAME}-build

release:
	docker push ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${version}

deploy:
	docker pull ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${version}
	docker tag ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${version} ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${environment}
	docker push ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${environment}

get-reporeg:
	@echo "${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}"

get-name:
	@echo "${NAME}"