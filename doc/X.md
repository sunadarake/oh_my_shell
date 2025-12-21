# X

Perlをシンプルに使うための便利関数集

## インストール

### GitHub経由でインストール

```bash
# cpanm
cpanm git@github.com:sunadarake/p5-X.git

# cpm
cpm install git@github.com:sunadarake/p5-X.git
```

### ローカルで開発する場合

```bash
git clone git@github.com:sunadarake/p5-X.git
cd p5-X
cpanm --installdeps . -L local
```

## 使い方

```perl
use X;

# ファイル操作
my $files = ff('dir');           # ディレクトリのファイルを再帰的に取得（絶対パス）
my $content = fg('file.txt');    # ファイルの中身を読み込む
fp('file.txt', $content);        # ファイルに内容を保存
md('dir/subdir');                # ディレクトリを再帰的に作成
cp('src.txt', 'dest.txt');       # ファイルをコピー
mv('old.txt', 'new.txt');        # ファイルを移動
rm('file.txt');                  # ファイルまたはディレクトリを削除

# JSON操作
my $data = jg('data.json');      # JSONファイルを読み込んでハッシュリファレンスを返す
jp('data.json', $data);          # データをJSONファイルに保存

# パス操作
my $basename = bn($path);        # ファイル名を取得
my $dirname = dn($path);         # ディレクトリ名を取得
my $realpath = rp($path);        # 絶対パスを取得
my $abspath = abs($path);        # 絶対パスを取得（rpのエイリアス）
my $relpath = rel($path);        # 相対パスを取得
my $cwd = pwd();                 # カレントディレクトリを取得

# HTTP操作
my $html = hg($url);             # HTTP GETリクエスト
my $result = hp($url, $data);    # HTTP PUTリクエスト
wget($url, 'file.txt');          # ファイルをダウンロード

# シェル操作
my $cmd_path = which('perl');    # コマンドのフルパスを返す
my $output = sh('ls', '-la');    # コマンドを実行して結果を返す
```

## 関数一覧

### ファイル操作 (X::File)

- `ff($dir)` - ディレクトリのファイルを再帰的に取得（絶対パス）
- `ffa($dir)` - ffと同じ
- `ffr($dir)` - 相対パスの配列を返す
- `fg($file)` - ファイルの中身を返す
- `fp($file, $content)` - ファイルに内容を保存
- `md($dir)` - ディレクトリを再帰的に作成
- `rm($path)` - ファイルまたはディレクトリを削除
- `cp($src, $dest)` - ファイルをコピー
- `mv($src, $dest)` - ファイルを移動

### JSON操作 (X::Json)

- `jg($file)` - JSONファイルを読み込んでハッシュリファレンスを返す
- `jp($file, $data)` - データをJSONファイルに保存

### パス操作 (X::Basename)

- `bn($path)` - ファイル名を取得
- `dn($path)` - ディレクトリ名を取得
- `rp($path)` - 絶対パスを取得
- `abs($path)` - 絶対パスを取得（rpのエイリアス）
- `rel($path, $root)` - 相対パスを取得
- `pwd()` - カレントディレクトリを取得

### HTTP操作 (X::Http)

- `hg($url, $param, $headers)` - HTTP GETリクエスト
- `hp($url, $body, $headers)` - HTTP PUTリクエスト
- `wget($url, $path)` - ファイルをダウンロード

### シェル操作 (X::Shell)

- `which($cmd)` - コマンドのフルパスを返す
- `sh(@args)` - コマンドを実行して結果を返す

## 特徴

- `use X;` すると自動的に `utf8::all` (Linux/Mac) または `Win32::Unicode::Native` (Windows) が適用される
- 全ての関数はシンプルで短い名前
- ファイル操作時に必要なディレクトリは自動作成
