FROM lukemathwalker/cargo-chef:latest-rust-bullseye AS chef
WORKDIR /twilight_http_proxy

FROM chef AS planner
RUN git clone https://github.com/twilight-rs/http-proxy
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /twilight_http_proxy/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release --bin twilight_http_proxy

FROM debian:bullseye-slim AS runtime
WORKDIR /twilight_http_proxy
COPY --from=builder /twilight_http_proxy/target/release/twilight_http_proxy /usr/local/bin
ENV DISCORD_TOKEN="the token"
ENTRYPOINT ["/usr/local/bin/twilight_http_proxy"]