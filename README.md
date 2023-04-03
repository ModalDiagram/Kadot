### NOTICE: STILL IN EARLY DEVELOPMENT

What is missing:
- complete README.me
- managing inherited versions and divergent files
- Uninstalling versions

What works:
- creating and installing isolated versions

<h1 align="center"> KADOT </h1>

### <a name="introduction"></a> INTRODUCTION
Kadot aims  to be a configuration manager that makes heavy use of [GNU Stow](https://www.gnu.org/software/stow/).
Main features:
- keeping track of multiple configurations for multiple platforms, each with its target directory
- easily interchangeable configurations
- clear directory tree that can be modified manually

### HOW IT WORKS
The key component of Kadot is the .kadot file which will be created in each directory that you want to manage with Kadot.
It is structured like [this](test_kadot/.kadot):

```vim
{
  "target": "$HOME/.config/anything",
  "info": "you can add anything here",
  "ignore": [],
  "versions": [
    {
      "name": "conf_1",
      "target": "",
      "inherits": "conf_2",
      "divergents": [],
      "ignore": []
    },
    {
      "name": "conf_2",
      "target": "$HOME/.config/another_target",
      "inherits": "",
      "divergents": [],
      "ignore": []
    }
  ]
}
```

Here we have:
- name: the name of the config, which must be the same as the folder name
- target: the directory where you want to install the configuration
- inherits: this version will be copied before installing the configuration (see [Multiple versions of the same config](#multiple_versions))


### <a name="multiple_versions"></a> Multiple versions of the same config
