# unix/init_claude.pl  windows/init_claude.ps1 を opencode にも対応する。

現在は Claude codeに対応しているが、　これを Opencode にも対応してほしい。


特に　permission やカスタムコマンドを Open code にも対応するファイルを作成するようにしてほしい。

OpenCode の仕様は以下の通り

コマンド
反復的なタスク用のカスタムコマンドを作成します。

カスタムコマンドを使用すると、TUI でコマンドを実行するときに実行するプロンプトを指定できます。

/my-command

カスタムコマンドは、/init、/undo、/redo、/share、/help などの組み込みコマンドに追加されます。 詳細はこちら。

コマンドファイルの作成
カスタムコマンドを定義するには、commands/ ディレクトリに Markdown ファイルを作成します。

.opencode/commands/test.md を作成します。

.opencode/commands/test.md
---
description: Run tests with coverage
agent: build
model: anthropic/claude-3-5-sonnet-20241022
---

Run the full test suite with coverage report and show any failures.
Focus on the failing tests and suggest fixes.

フロントマターはコマンドのプロパティを定義します。内容がテンプレートとなります。

/ に続けてコマンド名を入力して、コマンドを使用します。

"/test"

設定
カスタムコマンドは、OpenCode 設定を通じて、または commands/ ディレクトリに Markdown ファイルを作成することによって追加できます。

JSON
OpenCode 設定で command オプションを使用します:

opencode.jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "command": {
    // This becomes the name of the command
    "test": {
      // This is the prompt that will be sent to the LLM
      "template": "Run the full test suite with coverage report and show any failures.\nFocus on the failing tests and suggest fixes.",
      // This is shown as the description in the TUI
      "description": "Run tests with coverage",
      "agent": "build",
      "model": "anthropic/claude-3-5-sonnet-20241022"
    }
  }
}

これで、TUI で次のコマンドを実行できるようになります。

/test

Markdown
Markdown ファイルを使用してコマンドを定義することもできます。それらを次の場所に置きます。

グローバル: ~/.config/opencode/commands/
プロジェクトごと: .opencode/commands/
~/.config/opencode/commands/test.md
---
description: Run tests with coverage
agent: build
model: anthropic/claude-3-5-sonnet-20241022
---

Run the full test suite with coverage report and show any failures.
Focus on the failing tests and suggest fixes.

Markdown ファイル名がコマンド名になります。たとえば、test.md を使用すると、 あなたは実行します:

/test

プロンプト構成
カスタムコマンドのプロンプトは、いくつかの特別なプレースホルダーと構文をサポートしています。

引数
$ARGUMENTS プレースホルダーを使用してコマンドに引数を渡します。

.opencode/commands/component.md
---
description: Create a new component
---

Create a new React component named $ARGUMENTS with TypeScript support.
Include proper typing and basic structure.

引数を指定してコマンドを実行します。

/component Button

そして、$ARGUMENTS は Button に置き換えられます。

位置パラメータを使用して個々の引数にアクセスすることもできます。

$1 - 最初の引数
$2 - 2 番目の引数
$3 - 3 番目の引数
等々…
例えば：

.opencode/commands/create-file.md
---
description: Create a new file with content
---

Create a file named $1 in the directory $2
with the following content: $3

次のコマンドを実行します。

/create-file config.json src "{ \"key\": \"value\" }"

これは以下を置き換えます。

$1 と config.json
$2 と src
$3 と { "key": "value" }
シェル出力
!command を使用して、bash コマンド の出力をプロンプトに挿入します。

たとえば、テストカバレッジを分析するカスタムコマンドを作成するには、次のようにします。

.opencode/commands/analyze-coverage.md
---
description: Analyze test coverage
---

Here are the current test results:
!`npm test`

Based on these results, suggest improvements to increase coverage.

または、最近の変更を確認するには:

.opencode/commands/review-changes.md
---
description: Review recent changes
---

Recent git commits:
!`git log --oneline -10`

Review these changes and suggest any improvements.

コマンドはプロジェクトのルートディレクトリで実行され、その出力はプロンプトの一部になります。

ファイル参照
@ の後にファイル名を指定して、コマンドにファイルを含めます。

.opencode/commands/review-component.md
---
description: Review component
---

Review the component in @src/components/Button.tsx.
Check for performance issues and suggest improvements.

ファイルの内容はプロンプトに自動的に含まれます。

オプション
設定オプションを詳しく見てみましょう。

テンプレート
template オプションは、コマンドの実行時に LLM に送信されるプロンプトを定義します。

opencode.json
{
  "command": {
    "test": {
      "template": "Run the full test suite with coverage report and show any failures.\nFocus on the failing tests and suggest fixes."
    }
  }
}

これは必須の設定オプションです。

説明
description オプションを使用して、コマンドの動作の簡単な説明を入力します。

opencode.json
{
  "command": {
    "test": {
      "description": "Run tests with coverage"
    }
  }
}

これは、コマンドを入力すると TUI に説明として表示されます。

エージェント
オプションで、agent 設定を使用して、このコマンドを実行する agent を指定します。 これが subagent の場合、コマンドはデフォルトでサブエージェントの呼び出しをトリガーします。 この動作を無効にするには、subtask を false に設定します。

opencode.json
{
  "command": {
    "review": {
      "agent": "plan"
    }
  }
}

これはオプションの設定オプションです。指定しない場合、デフォルトで現在のエージェントが使用されます。

サブタスク
subtask ブール値を使用して、コマンドが subagent 呼び出しを強制的にトリガーします。 これは、コマンドがプライマリコンテキストを汚染せず、エージェントがサブエージェントとして動作するように強制する場合に便利です。 agent 設定で mode が primary に設定されている場合でも。

opencode.json
{
  "command": {
    "analyze": {
      "subtask": true
    }
  }
}

これはオプションの設定オプションです。

モデル
model 設定を使用して、このコマンドのデフォルトモデルをオーバーライドします。

opencode.json
{
  "command": {
    "analyze": {
      "model": "anthropic/claude-3-5-sonnet-20241022"
    }
  }
}

これはオプションの設定オプションです。

組み込み
OpenCode には、/init、/undo、/redo、/share、/help などのいくつかの組み込みコマンドが含まれています。 詳細はこちら。

ノート

カスタムコマンドは組み込みコマンドをオーバーライドできます。

同じ名前のカスタムコマンドを定義すると、組み込みコマンドがオーバーライドされます。

権限
どのアクションの実行に承認が必要かを制御します。

OpenCode は permission 設定を使用して、特定のアクションを自動的に実行するか、プロンプトを表示するか、ブロックするかを決定します。

v1.1.1 現在、従来の tools ブール値設定は非推奨となり、permission にマージされました。古い tools 設定は、下位互換性のために引き続きサポートされています。

アクション
各権限ルールは次のいずれかに解決されます。

"allow" — 承認なしで実行します
"ask" — 承認を求めるプロンプト
"deny" — アクションをブロックする
設定
権限をグローバルに (* を使用して) 設定し、特定のツールをオーバーライドできます。

opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "*": "ask",
    "bash": "allow",
    "edit": "deny"
  }
}

すべての権限を一度に設定することもできます。

opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": "allow"
}

詳細なルール (オブジェクト構文)
ほとんどの権限では、オブジェクトを使用して、ツール入力に基づいてさまざまなアクションを適用できます。

opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": {
      "*": "ask",
      "git *": "allow",
      "npm *": "allow",
      "rm *": "deny",
      "grep *": "allow"
    },
    "edit": {
      "*": "deny",
      "packages/web/src/content/docs/*.mdx": "allow"
    }
  }
}

ルールはパターンマッチによって評価され、最後に一致したルールが優先されます。一般的なパターンは、キャッチオール "*" ルールを最初に置き、その後により具体的なルールを置くことです。

ワイルドカード
許可パターンでは、単純なワイルドカードマッチングを使用します。

* は 0 個以上の任意の文字と一致します
? は 1 つの文字に正確に一致します
他のすべての文字は文字通り一致します
ホームディレクトリの展開
パターンの先頭で ~ または $HOME を使用して、ホームディレクトリを参照できます。これは、external_directory ルールに特に役立ちます。

~/projects/* -> /Users/username/projects/*
$HOME/projects/* -> /Users/username/projects/*
~ -> /Users/username
外部ディレクトリ
external_directory を使用して、OpenCode が開始された作業ディレクトリの外部のパスに触れるツール呼び出しを許可します。これは、パスを入力として受け取るすべてのツール (read、edit、glob、grep、および多くの bash コマンドなど) に適用されます。

ホーム展開 (~/... など) は、パターンの記述方法にのみ影響します。外部パスは現在のワークスペースの一部にはならないため、作業ディレクトリの外部のパスも external_directory 経由で許可する必要があります。

たとえば、これにより、~/projects/personal/ の下にあるすべてのものへのアクセスが許可されます。

opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "external_directory": {
      "~/projects/personal/**": "allow"
    }
  }
}

ここで許可されるディレクトリはすべて、現在のワークスペースと同じデフォルトを継承します。 read のデフォルトは allow であるため、オーバーライドされない限り、external_directory の下のエントリの読み取りも許可されます。読み取りを保持しながら編集をブロックするなど、ツールをこれらのパスで制限する必要がある場合は、明示的なルールを追加します。

opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "external_directory": {
      "~/projects/personal/**": "allow"
    },
    "edit": {
      "~/projects/personal/**": "deny"
    }
  }
}

信頼できるパスに重点を置いたリストを維持し、他のツール (bash など) の必要に応じて追加の許可または拒否ルールを追加します。

利用可能な権限
OpenCode の権限は、ツール名に加えて、いくつかの安全対策によってキー化されます。

read — ファイルの読み取り (ファイルパスと一致)
edit — すべてのファイル変更 (edit、write、patch をカバー)
glob — ファイルのグロビング (グロブパターンと一致)
grep — コンテンツ検索 (正規表現パターンと一致)
bash — シェルコマンドの実行 (git status --porcelain などの解析されたコマンドと一致します)
task — サブエージェントの起動 (サブエージェントのタイプと一致)
skill — スキルをロードしています（スキル名と一致します）
lsp — LSP クエリの実行 (現在は非細分性)
webfetch — URL を取得します (URL と一致します)
websearch — Web検索 (クエリと一致)
external_directory — ツールがプロジェクトの作業ディレクトリ外のパスにアクセスするとトリガーされます。
doom_loop — 同じ入力で同じツール呼び出しが 3 回繰り返されたときにトリガーされます。
デフォルト
何も指定しない場合、OpenCode は許容的なデフォルトから開始します。

ほとんどの権限はデフォルトで "allow" に設定されます。
doom_loop と external_directory のデフォルトは "ask" です。
read は "allow" ですが、.env ファイルはデフォルトで拒否されます。
opencode.json
{
  "permission": {
    "read": {
      "*": "allow",
      "*.env": "deny",
      "*.env.*": "deny",
      "*.env.example": "allow"
    }
  }
}

承認の要求
OpenCode が承認を求めるプロンプトを表示すると、UI は 3 つの結果を提供します。

once — このリクエストのみを承認します
always — 提案されたパターンに一致する今後のリクエストを承認します（現在の OpenCode セッションの残りの部分）
reject — リクエストを拒否します
always が承認するパターンのセットは、ツールによって提供されます (たとえば、bash の承認では通常、git status* のような安全なコマンドプレフィックスがホワイトリストに登録されます)。

エージェント
エージェントごとに権限をオーバーライドできます。エージェントの権限はグローバル設定とマージされ、エージェントルールが優先されます。 エージェントの権限について詳しくは、 をご覧ください。

ノート

パターンマッチングの詳細な例については、上記の詳細なルール (オブジェクト構文)セクションを参照してください。

opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": {
      "*": "ask",
      "git *": "allow",
      "git commit *": "deny",
      "git push *": "deny",
      "grep *": "allow"
    }
  },
  "agent": {
    "build": {
      "permission": {
        "bash": {
          "*": "ask",
          "git *": "allow",
          "git commit *": "ask",
          "git push *": "deny",
          "grep *": "allow"
        }
      }
    }
  }
}

Markdown でエージェントの権限を構成することもできます。

~/.config/opencode/agents/review.md
---
description: Code review without edits
mode: subagent
permission:
  edit: deny
  bash: ask
  webfetch: deny
---

Only analyze code and suggest changes.

ヒント

引数のあるコマンドにはパターンマッチングを使用します。 "grep *" は grep pattern file.txt を許可しますが、"grep" だけではブロックされます。 git status のようなコマンドはデフォルトの動作で機能しますが、引数を渡すときに明示的な許可 ("git status *" など) が必要です。

opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": {
      "*": "ask",
      "git *": "allow",
      "git commit *": "deny",
      "git push *": "deny",
      "grep *": "allow"
    }
  },
  "agent": {
    "build": {
      "permission": {
        "bash": {
          "*": "ask",
          "git *": "allow",
          "git commit *": "ask",
          "git push *": "deny",
          "grep *": "allow"
        }
      }
    }
  }
}

Markdownでエージェントの権限を構成することもできます。

~/.config/opencode/agents/review.md
---
description: Code review without edits
mode: subagent
permission:
  edit: deny
  bash: ask
  webfetch: deny
---

Only analyze code and suggest changes.

ヒント

引数のあるコマンドにはパターン マッチングを使用します。 "grep *" は grep pattern file.txt を許可しますが、"grep" だけではブロックされます。 git status のようなコマンドはデフォルトの動作で機能しますが、引数を渡すときに明示的な許可 ("git status *" など) が必要です。
