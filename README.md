Creating a new project from this template project
-------------------------------------------------

1. Check out this template project, to somewhere with parent directory where you'll want checkouts of the other projects.

2. From the checkout directory, run the duplicate script to create a new repository, replacing `<BitBucket username>` with your BitBucket username and `<New Repo Name>` with the name of the git repository you want to create (it should be prefixed with "play-"):

        . ./duplicate.sh -u <BitBucket username> -r <New Repo Name>
   This should duplicate the template project into a new repository on BitBucket, check out the project into the parent dir of the template project, and cd you into the new checkout.

4. From the newly created directory, open "StockChart" in Xcode (don't worry for now that ShinobiPlayUtils looks broken) and rename the project (click twice on project name in the Project Navigator, then follow the instructions, choosing to rename project content items). Close the project.

5. **Make sure you're in the checkout of the new project not the template project.** Run the rename script (replacing `<New Project Name>` with your new name):

        ./rename.sh <New Project Name>

6. Run:

        git submodule deinit
        git submodule init
        git submodule update
    
7. Edit **\<New Project Name\>.podspec** to fill in the summary, description, repo name, and frameworks.

8. Build your project.

9. Save a screenshot to **screenshot.png**.

10. Edit the rest of this file so it makes sense (the bits to change are in ***bold italics*** [or at least surrounded by lots of asterisks] - please remove the formatting as well as editing them!), and remove everything up to and including this point -> .

ShinobiPlay: Project Title (Objective-C/Swift)
=====================

***Description of project (include link to blog post if there is one)***

![Screenshot](screenshot.png?raw=true)

Building the project
------------------

In order to build this project you'll need a copy of Shinobi***Charts/Grids/Essentials/Gauges***. If you don't have it yet, you can download a free trial from the ***[ShinobiCharts/Grids/Essentials/Gauges website](link to appropriate section)***.

If you've used the installer to install Shinobi***Charts/Grids/Essentials/Gauges***, the project should just work. If you haven't, then once you've downloaded and unzipped Shinobi***Charts/Grids/Essentials/Gauges***, open up the project in Xcode, and drag Shinobi***Charts/Grids/Essentials/Gauges***.framework from the finder into Xcode's 'frameworks' group, and Xcode will sort out all the header and linker paths for you.

If you're using the trial version you'll need to add your license key. To do so, open up **MyProjectNameViewController.m** and add the following line inside `viewDidLoad`:

    [Shinobi***Charts/Grids/Essentials/Gauges*** setLicenseKey:@"your license key"];

Contributing
------------

We'd love to see your contributions to this project - please go ahead and fork it and send us a pull request when you're done! Or if you have a new project you think we should include here, email info@shinobicontrols.com to tell us about it.

License
-------

The [Apache License, Version 2.0](license.txt) applies to everything in this repository, and will apply to any user contributions.
