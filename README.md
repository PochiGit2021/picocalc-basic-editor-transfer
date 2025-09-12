# PicoCalc Transfer

**日本語** | [English](README_EN.md)

PicoMite BASIC プログラムを PC から PicoCalc デバイスにエディタ経由で簡易的に自動転送するためのバッチスクリプトです。確実に転送したい場合は、XMODEMを使うことをお勧めします。

## 機能

- **自動転送**: BASICプログラムファイルをシリアル通信経由でエディタに対して転送
- **GUIファイル選択**: ファイル指定なしで実行すると、ファイル選択ダイアログが開きます
- **自動実行**: 転送完了後、プログラムを自動的に実行
- **コマンドライン対応**: COMポートやファイルをオプションで指定可能

## 必要要件

- Windows 10/11
- PowerShell 5.1 以上
- PicoCalc (USB-C接続)

## インストール

1. このリポジトリをクローンまたはダウンロード
```bash
git clone https://github.com/PochiGit2021/picocalc-transfer.git
cd picocalc-transfer
```

2. PicoCalc を PC に USB 接続

3. デバイスマネージャーで COM ポート番号を確認

## 設定

デフォルト設定は `transfer.bat` 内で変更できます：

```bat
:: Default configuration
set "COMPORT=COM3"        :: デフォルトCOMポート
set "LOCAL_FILE=sample.bas"  :: デフォルトファイル
set "BAUDRATE=115200"     :: 通信速度
set "LINE_DELAY=1"        :: 行送信間隔（秒）
```


## 使用方法

### 基本的な使用

```bash
# GUIでファイルを選択して転送
.\transfer.bat

# 特定のファイルを転送
.\transfer.bat -f myprogram.bas

# COMポートを指定
.\transfer.bat -c COM6

# COMポートとファイルを両方指定
.\transfer.bat -c COM6 -f myprogram.bas
```

### オプション

| オプション | 説明 | 例 |
|------------|------|-----|
| `-c`, `--com` | COMポートを指定 | `-c COM6` |
| `-f`, `--file` | 転送するBASICファイルを指定 | `-f myprogram.bas` |
| `-h`, `--help` | ヘルプを表示 | `--help` |

### 転送プロセス

スクリプトは以下の手順で自動実行されます：

1. **COMポート設定** - 指定されたCOMポートを115200bpsで設定
2. **既存ファイル削除** - 同名ファイルがあれば削除
3. **メモリクリア** - `NEW` コマンドでプログラムメモリをクリア
4. **エディタ起動** - `EDIT` コマンドでエディタモードに入る
5. **ファイル転送** - プログラムを1行ずつ送信
6. **保存・終了** - F1キーでエディタを保存して終了
7. **プログラム実行** - `RUN` コマンドでプログラムを実行

## ファイル構成

```
picocalc-transfer/
├── transfer.bat          # メインスクリプト
├── sample.bas           # サンプルBASICプログラム
├── README.md            # このファイル（日本語ドキュメント）
├── README_EN.md         # 英語ドキュメント
└── LICENSE              # MITライセンス
```

## サンプルプログラム

`sample.bas` にはシンプルなテストプログラムが含まれています：

```basic
10 PRINT "Hello, PicoCalc!"
20 END
```

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルをご覧ください。