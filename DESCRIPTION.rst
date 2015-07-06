NEFIS
=======================

NEFIS is a library of functions designed for scientific programs. These programs are characterised by their large volume of input and output data. NEFIS is able to store and retrieve large
volumes of data on file or in shared memory. To achieve a good performance when storing
and retrieving data, the files are self-describing binary direct access files. Furthermore one of
the array dimensions may be variable and the sequence on the file can be prescribed. NEFIS
also allows users to store data in a machine-independent way on files, which means that the
data files can be interchanged between computer systems without having to be converted.
Data within NEFIS is divided into a hierarchical structure of groups, cells and elements. This
hierarchical structure is used to find the location in the file where the data should be stored or
retrieved. An element is the smallest unit which can be accessed at one time. One or more
elements make up a cell; and a group is defined as one or more dimensional arrays of cells.
This shows the logical cohesion of the data to be represented. Flags (in this context referred
as attributes) can be attached to groups as desired. These attributes can, for example, define a match between groups. They may also contain superscripts and subscripts for graphic
design. NEFIS can exist of one file for input and retrieval of data (i.e. a definition and a data
part). The previous NEFIS version needed two files for input and retrieval of data (i.e. a data
file and a definition file). A data file contains the data supplied by the user and the attributes
that have been added. The definition file contains the description of the structure. The relationship between a data file and a definition file is determined by the application. This means
that one definition file can be used by various data files. The opposite is also possible (i.e. a
data file can be used from different definition files). More over, a well-defined definition file is
able to scope all data files of a company.
