# go-docker

A walkthrough of building Golang Docker image improvement

## Simplest

We start from the simplest example code and Dockerfile, check the code snippets: [Source code](./simple/main.go) \
This source code can be easily build by running the command `go build -v -o ./out/main ./src/simple/main.go` \
Also the build can be achieved by using the following Dockerfile: [Dockerfile](./dockerfiles/simple.Dockerfile) \
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

## Dependencies

We add some dependencies to our [source code](./dependencies/main.go), and use [Go modules](https://go.dev/blog/using-go-modules) to manage dependencies. \
In [dependecies.Dockerfile](./dockerfiles/dependecies.Dockerfile), we copy `go.mod` and `go.sum` before copying other files \
so that Docker will use the module downloaded intermediate image cache if the `go.mod` and `go.sum` files are not changed.

## Docker Buildkit

Enable BuildKit builds by setting `DOCKER_BUILDKIT=1` environment variable when executing `docker build` command. \
Besides, set Dockerfile version to 1.2. by adding `# syntax=docker/dockerfile:1.3` at the top of dockerfile. \
Docker buildkit allows the build container to cache directories for compilers and package managers by adding `--mount=type=cache` to `RUN` command in Dockerfiles. \
As shown in [buildkit.Dockerfile](./dockerfiles/buildkit.Dockerfile), we mount a cache to `GOMODCACHE` directory, which is the directory where the go command stores downloaded module files. \
By doing so, we can spare a lot of time for re-downloading packages for every builds.

## Mount Context, GOCACHE, and GOMODCACHE

In the above section, we mount `GOMODCACHE` to avoid downloading packages for every builds. \
Aside from that, we can also mount `docker build context` and `GOCACHE` to the builder. \
In previous shown dockerfiles, we do not really need to keep Go source code files in the images, but just need to compile them. \

1. By adding `--mount=target=.` flag to mount the `docker build context` to the builder, we can not only save an intermediate image layer doing `COPY` command.
2. We can set `--mount=type=cache,target=/root/.cache/go-build` flag to `RUN go build` command to mount the build cache, which contains compiled packages and other build artifacts, to Go's compiler cache folder. \
By doing so, we don't need to rebuild every earlier-compiled packages.
3. Set `--mount=type=cache,target=/go/pkg/mod` flag to `RUN go build` command to mount the mod cahce.

Check [final.Dockerfile](./final.Dockerfile) for the final version of dockerfile.

## Conclusion

We begin from a very simple code and dockerfile to the final version. \
We show how to improve Go Docker building process:

- Multi-stage build
- .dockerignore
- Docker buildkit
  - Mount build context
  - Mount GOMODCACHE
  - Mount GOCACHE

Hope this post can help you improve your Go Docker images!
