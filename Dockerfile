FROM alpine:3.19 as v86-builder
WORKDIR /v86

# build-base와 git 패키지 추가
RUN apk add --update curl build-base clang openjdk8-jre-base npm python3 git
# rustup 설치 후 ENV로 PATH를 영구적으로 설정
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}" 
RUN rustup target add wasm32-unknown-unknown

# Git 저장소 클론 및 서브모듈 업데이트 (copy.sh/v86의 실제 경로로 대체)
RUN git clone https://github.com/copy/v86.git .
RUN git submodule update --init --recursive

# PATH 설정 없이 make all 실행
RUN make all && rm -rf closure-compiler gen lib src tools .cargo cargo.toml Makefile

FROM python:3.10.13-alpine3.19
WORKDIR /v86

COPY --from=v86-builder /v86 .

ARG PORT=8000
CMD python3 -m http.server ${PORT}

EXPOSE ${PORT}
