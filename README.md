# go-docker

A walkthrough of building Golang Docker image improvement

## Simplest

We start from the simplest example code and Dockerfile, check the code snippets: [Source code](./simple/main.go) \
This source code can be easily build by running the command `go build -v -o ./out/main ./src/simple/main.go` \
Also the build can be achieved by use the following Dockerfile: [Dockerfile](./dockerfiles/simple.Dockerfile) \
Run `docker build --progress=plain -f ./dockerfiles/simple.Dockerfile -t go-docker-simple .`

## Multi-stage Build

In order to keep the final image size down, we needed to do some shell script tricks to keep only the artifacts, which would be copied to the final image, and remove all other unnecessary files. \
Use multi-stage build to simplify this process and still reduce the final image size. \

In [multi-stage Dockerfile](./dockerfiles/multi-stage.Dockerfile), we can see 2 `FROM` statements. \
Each `FROM` statement can use diffrent base, and begins a new stage of the build. \
Also, we can name each build stage by specified `AS {name}` after the `FROM` statement, e.g., `FROM golang:1.17-alpine AS compiler`. \
We copy the artifact from the compiler stage to the final stage. \
By doing so, we can leave other unnecessary files such as installed Go packages, intermediate artifacts, and source codes behind. \
The final image bases on `alpine` and only copy the compiled binary file to it, which reduces the image size. \
Run `docker build --progress=plain -f ./dockerfiles/multi-stage.Dockerfile -t go-docker-multi-stage .` \
Check the final image size by running `docker images | grep go-docker`, and the result is as following:

```sh
go-docker-simple                     latest                   b31fe5c7bca1   54 seconds ago      317MB
go-docker-multi-stage                latest                   f8ba5b915c94   About an hour ago   7.35MB
```

## .dockerignore

By default, `docker build` command passes everything in the context directory to the builder. \
To increase the build's performance, add a `.dockerignore` to the context directory to exclude files and directories. \
For example, in my [.dockerignore](./dockerignore) excludes `.git` directory and compiled output binary files in `out` directory.
