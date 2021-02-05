# SelectedExportLog プラグイン

## 概要

ログの一覧画面について選択したログを CSV 形式でダウンロードします

## 動作環境

- Movable Type 6
- PowerCMS 4,5

## インストール

1. ZIP アーカイブ *SelectedExportLog.zip* を解凍し、サーバ上のプラグインディレクトリへ *SelectedExportLog* を設置する

    例 :

        $MT_HOME/plugins/SelectedExportLog

    ※ `$MT_HOME` は CMS のインストール先を指します

1. 管理画面へログインする
1. システムレベルのプラグイン設定の一覧に SelectedExportLog が表示されていることを確認する

## 使い方

ログの一覧画面についてチェックボックスでログを選択し、「ログをダウンロード(CSV)」ボタンをクリックすると CSV ファイルのダウンロードが始まります。

### CSV ファイル

CSV ファイルには以下の列が出力されます。

- id (ID)
- timestamp (日時)
- ip (IP アドレス)
- weblog (ウェブサイト/ブログの名前)
- message (ログ)
- metadata (メタデータ)

## 更新履歴

- ver.0.46 (2021/02/05)
    - 「全N件が選択されています」を選択したとき、全N件がダウンロードできない問題の対策
- ver.0.45 (2020/04/30)
    - 公開

## 奥付
- Alfasado Inc.
- https://alfasado.net/
- 2020/04/30
