# ASP3_FSP_EWARM

TOPPERS/ASP3 と Renesas FSP とIAR Embedded Workbench for ARM(EWARM)を組み合わせたサンプルプロジェクトです。

このリポジトリには２つのサンプルを用意しました。FSPのコード生成とEWARM向けのオプション設定などが終わった`sample`とFSPのコード生成ゆあEWARMのオプション設定を自分で設定しながら実施する`sample1`があります。
`sample`は、TOPPERS/ASP3 RTOS 上で動くタスクが UART にバナーとメッセージを出力するサンプルが動作します(Toppers標準のサンプルです)・
`sample1`は、TOPPERS/ASP3 RTOS でタスクが、"Start Task"の出力するサンプルです。


- Renesas FSP (Flexible Software Package) と TOPPERS/ASP3 RTOS の連携方法
- CMake + EWARMによるクロスコンパイル環境の構築
- ASP3 のタスク・セマフォ・サービスコールの基本的な使い方

## フォルダ構成

- `asp3/`: 共通の TOPPERS/ASP3 RTOS 本体
- `ek_ra6m5/`: EK-RA6M5 向けのボードフォルダ
- `ek_ra6m5/sample/`: EK-RA6M5 のサンプルアプリケーション(FSPコード生成済み、EWARM設定済み)
- `ek_ra6m5/sample1/`: EK-RA6M5 のサンプルアプリケーション（FSPコード未精製、EWARM未設定）


## 対応コンパイラ
IAR Embedded Workbench for ARM(EWARM)を使用。
今回使用したバージョンは9.70.4になります。

| ツール | コマンド名 | 
|---|---|
|Cコンパイラ | iccarm.exe |
|アセンブラ |  iasmarm.exe |
|リンカ     |  ilinkarm.exe |
|SREC生成  |  ielftool.exe |


## 関連ツール

| 項目 | バージョン |
|------|-----------|
| Renesas FSP | 6.2.0 |
|CMake |  インストールしてPATHに設定してください。|
|PYTHON     |インストールしてPATHに設定してください。 |
|Ninja  |  EWARMにインストールしたものが利用できます。EWARMインストールフォルダの\common\binにあるので、ここもPATH設定してください。 |
|Tera Term     | |


## サンプルの開き方

対応する README を参照してください。

| ボード | サンプル |   詳細手順  |
|--------|----------|----------------|
| EK-RA6M5 | sample| [ek_ra6m5/sample/README.md](ek_ra6m5/sample/README.md)  |
| EK-RA6M5 | sample1| [ek_ra6m5/sample1/README.md](ek_ra6m5/sample1/README.md)  |


## 新規プロジェクト作成ガイド

`sample`をベースに作成してください。
基本的な作業についてはこちらの
