# ESLint Action
A GitHub Action to run [ESLint](https://eslint.org/) based on the rule set defined. Features included as part of this action:
- Analyse the files changed between the current and target branch, the identified files changed in a GitHub pull request, or analyse based on a file path / rule set
- Generate warning and error notifications based on the ESLint rules defined (errors will cause the action to fail)
- Setup ESLint based on package.json or just install ESLint directly

## Example GitHub Action Workflow File
```
name: ESLint Static Code Analysis
on:
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v2
        with:
          # Need to set fetch depth to 0 for incremental diffs to grab the target branch
          fetch-depth: '0'
      - name: Run ESLint
        uses: synergy-au/eslint-action@v1
        with:
          rules-path: './.eslintrc.json'
          setup-from-package-json: 'true'
```
## Inputs
### analyse-all-code
Used to determine whether you just want to analyse the files changed or the whole repository.
- required: false
- default: 'false'

### auth-token
If you are looking to compare the file difference based on the GitHub pull request, you will need to specify the [GitHub secrets token](https://docs.github.com/en/actions/reference/authentication-in-a-workflow)
- required: false

### eslint-version
The version of ESLint you would like to run. Applicable when you aren't installing via package.json.
- required: false
- default: '7.23.0'

### file-diff-type
Choose whether you want the file comparison to be based on a git diff or based on the files changed specified on the GitHub pull request. Note that if you use the GitHub pull request option, this action will only work on a pull request event. Options to set this are either `git` or `github`.'
- required: false
- default: 'git'

### file-path
Path to the sources to analyse. This can be a file name or a directory. Should be used when analysing the whole code base.
- required: false
- default: '**/**'
  
### rules-path
The ESLint ruleset file you want to use for the analysis.
- required: false
- default: './eslintrc.json'
  
### setup-from-package-json
You can manage your ESLint setup via package.json configuration in your project. Recommended if you are working with plugins.
- required: false
- default: 'false'