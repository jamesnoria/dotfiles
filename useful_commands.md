# This md file try to display some helpful commands that are too long to remember :lol:

- Copy to a .txt file all my vscode extensions:
    ```shell
    code --list-extensions | tee ./vscode-extensions.txt
    ```
- Install vscode extensions:
    ```shell
    xargs -n1 code --install-extension < ./vscode-extensions.txt
    ```
- Fix problems with django-postgresql:
    ```shell
    sudo apt-get install libpq-dev python3-dev
    ```
