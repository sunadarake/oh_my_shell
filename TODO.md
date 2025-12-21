# perl/init_python_scripts.pl を作成する。

Pythonのスクリプト群を作るプロジェクトの雛形を作る。

引数には１つ受け取る。
その引数がpythonscriptのプロジェクト名になる。
以下の処理を書くこと。

- doc/X.md に記載がある X moduleを使うこと。
- uv があるかチェックする
- uv init --package sample_project を実行する
- cd をする。　perl/init_claude.plと同じように CLAUDE.mdと.claude/settings.jsonを作成する。
- CLAUDE.mdは doc/claude_script.mdと同じようにすること。
