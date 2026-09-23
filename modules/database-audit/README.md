# Reusable module for setting up audit DB objects

Provides scripts for creating generic DB objects to support user action audit.

**NB!** It's not an independent project and can be used only as a module of another system.

## 1. Development guides

### 1.1. DB stored procedure and function scripts

DB object declaration scripts are stored in a directory [code](code/). Each DB schema should have a matching subdirectory there. Functions/procedures/types are declared in files with the name pattern `R__<object_name>.sql`, where
* `<object_name>` is a placeholder for the function/procedure/type/etc. name.

These files can be overwritten if a change for the DB object is required. Content of the file should start with
```
CREATE OR REPLACE
```

Example:

to create a procedure `get_data` in schema `test`, need to create a file `code/test/R__get_data.sql`.

### 1.2. DB version update scripts

Changes in DB structure and classifier data should be deployed via directory [versions](versions/). Multiple version change files are grouped under the subdirectory named `<X>.<Y>.<Z>`. Each file is named according to the pattern `V<X>_<Y>_<Z>_<YYYYMMDDHHmmSS>__<description>.sql`, where 
* `<X>` is a major version number
* `<Y>` is a minor version number 
* `<Z>` is a patch number
* `<YYYYMMDDHHmmSS>` is a script creation date and time
* `<description>` is a brief change description in English in lower case where words separated with `_` symbol.

Scripts from these files should be run once and only once for the single DB. Their execution is tracked in a `public.changelog` table with a date, time and a checksum and changing original content will result in a conflict. If after version script was applied any additional changes, typo fix or other corrections are required, they should come as a separate file in hte same version subdirectory. 

Example:

to create a change script in version `0.0.1`, need to create a file : `versions/0.0.1/V0_0_1_20220117125300__add_new_column_to_table.sql`.

> *NB! There should not be more than one script with a timestamp within a second!*

### 1.3. Developing module's scripts

Before pushing changes to remote repo it's recommended to test them on local machine. Since current module is not independent and doesn't create it's own DB instance, testing should be conducted within main project that references current module.

1. Develop required changes in the main project's `modules` folder
1. To test changes execute DB migration for the main project as per instructions
1. When changes are complete, commit changes to the module's remote repo from the main project's `modules` folder
1. Make another commit for the main project with updated submodule repo commit reference

## 2. Database users

* `lx`
* `lx_public`
