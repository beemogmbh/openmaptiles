# naviki_poi
The naviki_poi layer is a poi layer optimized for the needs of beemo GmbH.

Each point of interest exported by this layer will match a category which helps to generalize what this poi is about.

Each point of interest exported by this layer will have a rank which can be used to reduce the density of pois at a given zoom level.

## category
The categories are definied by beemo GmbH. Definitions for the categories can be found in the definitions.yaml file.
The category is being assigned by running import-rank-and-category docker.
Running import-rank-and-category docker will always recalculate the rank as well, as changing categories has an effect on pois rank.

#### Editing/adding new categories:
Remember to check if the tag/field keys that are necessary to define the new category are defined for import in the mapping.yaml file.
If not, it's necessary to add those tag/field keys to import in the mapping.yaml file and import-osm docker needs to be run again, 
otherwise this tag will never be imported and the new defined category will probably never be assigned to any poi.

Remember to run import-rank-and-category docker after editing/ adding new category definitions in the definitions.yaml file in order to
reassign categories to pois using the new definitions.

#### Removing/merging categories:
Remember to run import-rank-and-category docker after deleting or merging category definitions in the definitions.yaml file in order to
reassign categories to pois using the new definitions.

## rank
The categories are definied by beemo GmbH. Definitions for the rank can be found in the definitions.yaml file.
The rank is being precalculated by running import-rank or import-rank-and-category docker. These processes will assign to each
categorized poi an initial rank. The final rank will be calculated localy (depending on the poi's coordinates)
when running generate-tiles docker.

The precalculated rank goes from 0 to infinity. The higher the rank, the more important the poi is and the bigger the chance to appear
on the map on lower zoom levels.

#### Changing rank definitions:
Remember to run import-rank docker after deleting or merging category definitions in the definitions.yaml file in order to
reassign categories to pois using the new definitions.

## definitions.yaml
This file contains rank and category definitions for the pois and other fields that are necessary for other projects, which are not
relevant for this layer. 

Category and rank definitions have to follow a specific pattern. The pre-defined definitions.yaml file can be used as an example.
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

#### rank
Rank definitions should follow the "rankDefinition:" entry. Only rank definitions for elements that contain a "catName:" entry will be regarded.
Rank definitions can be assigned to each category separately and/or to all categories at once using the pre-defined for_all_rank_criteria
entry.

Each element except AND will give the poi that matches the definition and contains the category name specified in catName one more point.
This means for example that if the rankDefinition contains an OR element followed by 5 tag elements, each of those tag elements can bring
one point.

AND element will always bring just one point, regardless the number of element matches followed by the AND element.
This means for example that if the rankDefinition contains an AND element followed by 5 tag elements, the poi will gain one point if he
matches all of those 5 tag elements.

## mapping.yaml
Mapping should contain at least all tag key values mentioned in the definitions.yaml file.

## layer.sql
Poi's rank is being selected here and recalculated depending on the poi's coordinates.
By default only categorized records will be exported. The number of exported records will be reduced by zoom level < 14,
prioritizing the poi's with the highest rank.

## build
Run import-rank-and-category after the import-osm call.

Make sure the environment variables are set properly.

It's recommended to run test-rank-and-category before running import-rank-and-category.

## important
Do not change the column name of the tags in the mapping file.

Do not generate vector tiles before running import-rank-and-category docker. Only records containing a catagory will be exported.