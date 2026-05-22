# CLAUDE.md
## Base workflow
#### If the request is a question or discussion: 
   1. Always think twice 
   2. Always validate the answer with a second source before giving it to me. If the answer is not correct, give me the correct answer and explain why the first answer was wrong.
   3. Give me the answer with sources and references. If the answer is based on a personal opinion, clearly state that it is an opinion and provide reasoning for that opinion.

#### If the request is to make some change to the system, product, code or etc:
   1. Always give me the plan before you make the change. 
   2. If I approve the plan, then make the change. 
   3. If I don't approve the plan, then give me an updated plan based on my feedback and wait for my approval before making the change.
   4. If the request is to write some code: 
      1. Make sure your add or change the minimum amount of code necessary to achieve the desired outcome.
      2. Always try to use the existing code and functions as much as possible. If you need to add new code, make sure it is well-documented and follows the existing coding style.
      3. When trying to use existing code and functions, always check the original design and purpose of the code to make sure it is being used correctly. If you find that the existing code is not suitable for the new purpose, then you can consider adding new code, but make sure to explain why the existing code is not suitable and how the new code will address the issue.
      4. Always give me the code with comments explaining what each method or class of the code does. 
      5. Always test the code before giving it to me. If there are any errors, fix them and explain what the errors were and how you fixed them.
      6. Rules for change logs:
         1. If there isn't a CHANGELOG.md file, create one. If it has CHANGELOG.md, make sure to update it with the changes you made. The changes should include features and bugfix as release note, db change, architecture change, public method change, file path changes and etc as technical information. If the same or similar changes made in previous log history, mention them all as reference in latest log;
         2. Don't need change log each commit, my change should log each PR, before PR merged, summary changes in log instead of simply add;
         3. Include date for each PR change log.
      7. Version upgrade: 
         1. Bump up the version number each pull request if there are VERSION files, if not, update package.json or pyproject.toml. 
         2. According to the changes you made. If it's a minor change, bump the patch version. If it's a new feature, bump the minor version. If it's a breaking change, bump the major version. Always follow semantic versioning principles.
   5. If there are any questions or discussions from me, follow the base workflow for question or discussion to answer them.

## Memory from previous works
#### Coding style:
#### Prefer Answer style: