# =================================================================
# Stage 1: Builder
# このステージでは、ソースコードのコンパイルに必要なツールとライブラリをインストールし、
# PotreeConverterをビルドします。
# =================================================================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# 1. 依存関係のインストール
# laszipのヘッダファイル等を含むliblaszip-devを明示的にインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    ca-certificates \
    cmake \
    libtbb-dev \
    liblaszip-dev

# 2. ソースコードの取得
WORKDIR /app
RUN git clone https://github.com/potree/PotreeConverter.git --recursive .

# 3. ビルドの実行
RUN mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc)


# =================================================================
# Stage 2: Final Image
# このステージでは、ビルドされた実行可能ファイルと、その実行に最低限必要な
# ライブラリのみを軽量なベースイメージにコピーします。
# =================================================================
FROM ubuntu:22.04

# ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
# 修正点：apt-getでライブラリをインストールするのではなく、
# builderステージから必要な共有ライブラリを直接コピーする方式に変更。
# ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

# ビルダー(builder)イメージからコンパイル済みの実行可能ファイルをコピー
COPY --from=builder /app/build/PotreeConverter /usr/local/bin/PotreeConverter

# PotreeConverterが実行時に依存するライブラリをbuilderからコピーする
# ワイルドカード(*)を使い、シンボリックリンクと実体ファイルの両方をコピー
COPY --from=builder /usr/lib/x86_64-linux-gnu/libtbb.so* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/liblaszip.so* /usr/lib/x86_64-linux-gnu/

# システムに新しいライブラリを認識させるために、ライブラリキャッシュを更新
RUN ldconfig

# データを処理するための作業ディレクトリを作成・指定
WORKDIR /data

# コンテナ実行時のデフォルトコマンドとしてPotreeConverterを設定
ENTRYPOINT ["/usr/local/bin/PotreeConverter"]

# コンテナが引数なしで実行された場合にヘルプメッセージを表示
CMD ["--help"]
