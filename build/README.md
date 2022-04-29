## Build and Release

### When to Build
* Code, repo or branch change
    * TNG
    * Q2Pro
    * q2admin
* New Mac builds ready
    * q2probuilds/{ARCH}/q2pro
    * q2probuilds/{ARCH}/q2proded
    * q2probuilds/{ARCH}/*lib
    * q2probuilds/{ARCH}/game*.so

1. Create a pull request from `main` to `ci`
1. Verify all commits are being merged that you want
1. Complete PR, Merge PR
1. Wait for build jobs to complete

### Github Release
* Artifacts built and ready to deploy to Github Releases, Itch.io, Steam
* Go to Releases
    * Create a new release
    * Fill in updates
    * Update semver tag

### Steam and Itch.io Release
1. Go to Actions
1. Select the Release you want to run
1. Supply the same release tag as Github Release 
