# naviki_poi
The naviki_poi layer is a poi layer optimized for the needs of beemo GmbH.

Each point of interest exported by this layer will match a category which helps to generalize what this poi is about.

Each point of interest exported by this layer will have a rank which can be used to reduce the density of pois at a given zoom level.

Each point of interest exported by this layer contains a priority field which is being used to determine it's rank.

## category
The categories are definied by beemo GmbH. Definitions for the categories can be found in the definitions.yaml file.
The category is being assigned by running import-priority-and-category docker.
Running import-priority-and-category docker will always recalculate the priority as well, as changing categories has an effect on poi's priority.

#### Editing/adding new categories:
Remember to check if the tag/field keys that are necessary to define the new category are defined for import in the mapping.yaml file.
If not, it's necessary to add those tag/field keys to import in the mapping.yaml file and import-osm docker needs to be run again, 
otherwise this tag will never be imported and the new defined category will probably never be assigned to any poi.

Remember to run import-priority-and-category docker after editing/ adding new category definitions in the definitions.yaml file in order to
reassign categories to pois using the new definitions.

#### Removing/merging categories:
Remember to run import-priority-and-category docker after deleting or merging category definitions in the definitions.yaml file in order to
reassign categories to pois using the new definitions.

## rank
The rank will be calculated localy (depending on the poi's coordinates) considering it's priority when running generate-tiles docker. 
Poi's with the highest priority in a given area will be exported first. It's possible to control the density of exported poi's by limiting the maximum rank for exported poi's. 


## priority
The priority is definied by beemo GmbH. Definitions for the priority can be found in the definitions.yaml file.
The priority is being precalculated by running import-priority or import-priority-and-category docker. These processes will assign to each
categorized poi a priority.

The precalculated priority goes from 0 to infinity. The higher the priority, the more important the poi is and the bigger the chance to appear
on the map on lower zoom levels.

#### Changing priority definitions:
Remember to run import-priority docker after deleting or merging category definitions in the definitions.yaml file in order to
reassign categories to pois using the new definitions.

## definitions.yaml
This file contains priority and category definitions for the pois and other fields that are necessary for other projects, which are not
relevant for this layer. 

Category and priority definitions have to follow a specific pattern. The pre-defined definitions.yaml file can be used as an example.
Following elements can be used for defintions:

###### AND: followed by at least one element. 
A poi needs to contain all elements that follow the AND-element to match the definition.

###### OR: followed by at least one element.
A poi needs to contain at least one of the elements that follow the OR-element to match the definition.

###### NOT: followed by one (any) element.
A poi must not contain the element that follows the NOT-element to match the definition.

###### tag: folloewd by a key and a value entry.
A poi must contain the tag specified by this element to match the definition.

###### field: followed by a key and a value entry.
A poi must contain the field specified by this element to match the definition.

##### Special cases:
A definition starting with many elements without being followed by an AND or OR element will be automatically assigned to an OR element.

A tag or field having '*' as value means that a tag with any value will match, as long as the value is not empty and the keys are equal.

A tag or field having an empty key or value entry will be ignored.

If two tags or fields belonging to the same AND or OR clause have identical keys, the first tag or field will be ignored.

#### category
Category definitions should follow the "catDefinition:" entry. Only categories that contain a "catName:" entry will be regarded.
If a poi matches the defined category, the category will be assigned to that poi. If a poi matches more than one categories,
the poi will be duplicated as many times as category definitions it matches and each category that matches the poi will be assigned to
one of the copies.

#### priority
Priority definitions should follow the "priorityDefinition:" entry. Only priority definitions for elements that contain a "catName:" entry will be regarded.
Priority definitions can be assigned to each category separately and/or to all categories at once using the pre-defined for_all_priority_criteria
entry.

Each element except AND will give the poi that matches the definition and contains the category name specified in catName one more point.
This means for example that if the priorityDefinition contains an OR element followed by 5 tag elements, each of those tag elements can bring
one point.

AND element will always bring just one point, regardless the number of element matches followed by the AND element.
This means for example that if the priorityDefinition contains an AND element followed by 5 tag elements, the poi will gain one point if he
matches all of those 5 tag elements.

## mapping.yaml
Mapping should contain at least all tag key values mentioned in the definitions.yaml file.

## layer.sql
Poi's priority is being selected here and the rank is being calculated depenting on the selected priority and the poi's coordinates.
By default only categorized records will be exported. The number of exported records will be reduced at zoom levels < 14,
exporting the poi's with a lower rank than set a a limit.

## build
Run import-priority-and-category after the import-osm call. By default, it will be run when running ./quickstart.sh.

If you never before run the import-priority-and-category process with your actual database, you will need to run import-priority-and-category.

If you've already calculated the categories for the points of interest and if your changes in the definition.yaml file refer only to the priority of the pois,
you can just recalculate the priority by running import-priority. 

Make sure the environment variables are set properly.

#### environment variables
Define the correct connection data for PostGIS SQL Database. The connection data will be used int the categorizing and prioritizing process.

Set the cpu count that is going to be used for the categorizing and prioritizing process.
If the cpu count is less than 1 or greater than the cpu count avariable on the given machine, the 
maximum possible cpu count will be used.

It's recommended to run test-priority-and-category before the categorizing and/or prioritizing process.

## important
Do not change the column name of the tags in the mapping file.
If you do so, remember to redefine the default constants in the Constants.py file.

Do not generate vector tiles before running import-priority-and-category docker. Only records containing a catagory will be exported.
You will run into an error if you try to generate vector tiles without running import-priority-and-category docker first.