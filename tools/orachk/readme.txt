orachk readme - Oracle configuration audit tool
----------------------------------------------------------------------------------

NOTE:  Please see RACcheck Configuration Audit Tool Statement of Direction - name change to ORAchk (Doc ID 1591208.1)

PURPOSE
=========
the tool is designed to audit various important configuration settings and "health checks" within an Oracle environment including 

Oracle Real Application Clusters (RAC) databases
non-RAC databases
MAA configuration
Oracle Golden Gate configuration 
EBS checks 
preinstall configuration
pre-upgrade configuration
Solaris system configuration

and other Oracle products over time.

PLATFORMS SUPPORTED
======================
At this time, the tool is supported on the following UNIX platforms:

  - Linux x86-64* (Enterprise Linux, RedHat and SuSE 9, SuSE 10 & SuSE 11)
  - Oracle Solaris SPARC (Solaris 10 and 11)
  - Oracle Solaris x86-64 (Solaris 10 and 11)
  - AIX **
  - HPUX**

         * 32-bit platforms not supported, no planned support for Linux Itanium
        **Requires BASH Shell 3.2 or higher to be installed

DATABASE VERSIONS SUPPORTED
============================
At this time, the tool is supported on the following database versions:

  - 10gR2
  - 11gR1
  - 11gR2
  - 12gR1

USAGE
======
Run the tool as the Oracle RDBMS software owner (eg., oracle) if Oracle software installed.

the tool can be run with following  arguments

  1   -a - performs all checks, best practice and database/clusterware patch/os recommendations.
  2.  -b - best practice recommendations only
  3.  -p - database/clusterware patch recommendations only
  4.  -f - offline, performs analysis for all
  5.  -u - performs pre-upgrade checks
  6.  -S - please see the AUTOMATION section of the UserGuide for more on this argument
  7.  -s - please see the AUTOMATION section of the UserGuide for more on this argument
  8.  -c - for use when checking individual components
              eg., orachk -a -c ASM
              or    orachk -a -c ACFS
  9.  -o - for invoking various optional functionality
                v|verbose to display PASSing audit checks as well as non-PASSIng
                eg., orachk -a -o v
                or orachk -a -o verbose
                or orachk -a -c DBM -o verbose
10.  -v - returns the version of the tool
                eg., orachk -v
11. -m      exclude checks for Maximum Availability Architecture scorecards(see user guide for more details)

See the ORAchk User Guide for the most up to date information

ORAchk Collection Manager
==================

ORAchk Collection Manager is a companion application to ORAchk, RACcheck and Exachk.  When customers have many systems for which they use ORAchk to periodically check their configurations it is difficult to manage these on a system by system basis.  ORAchk has long had the ability to upload the results of its audit checks into a database automatically at run time.  This capability is documented in the ORAchk User Guide.  However, it was up to the customer to create a custom front-end to that data for reporting purposes and trend analysis.  Now, with ORAchk Collection Manager Oracle provides this Application Express application to be used as a dashboard in which they can track their ORAchk, RACcheck and Exachk collection data in one easy to use interface.  Customers can monitor collections for the following:

- Business Units
- Systems within Business Units, by DBA Manager and DBA
- Trends for findings most frequently Failing and Warning
- Results for automatic comparison between most recent and last collections per system
- Incidents created for tracking correction of issues
- Browsing the collections by various filter criteria

See Collection Manager for ORAchk, RACcheck and Exachk (Doc ID 1602329.1) for more details