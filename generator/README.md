# WG Doc builder

This folder contains scripts to automatically generate documentation about the
different Special Interest Groups (SIGs), Working Groups (WGs),
User Groups (UGs) and Committees of Kubernetes. The authoritative
source for SIG information is the [`wgs.yaml`](/wgs.yaml) file in the project root.
All updates must be done there.

The schema for this file should be self explanatory. However, if you need to see all the options, check out the generator code in `app.go`.

The documentation follows a template and uses the values from [`wgs.yaml`](/wgs.yaml):

- Header: [`header.tmpl`](header.tmpl)
- List: [`list.tmpl`](list.tmpl)
- SIG README: [`sig_readme.tmpl`](sig_readme.tmpl)
- WG README: [`wg_readme.tmpl`](wg_readme.tmpl)
- UG README: [`ug_readme.tmpl`](ug_readme.tmpl)
- Committee README: [`committee_readme.tmpl`](committee_readme.tmpl)

**Time Zone gotcha**:
Time zones make everything complicated.
And Daylight Saving time makes it even more complicated.
Meetings are specified with a time zone and we generate a link to http://www.thetimezoneconverter.com/ so people can easily convert it to their local time zone.
To make this work you need to specify the time zone in a way that the web site recognizes.
Practically, that means US pacific time must be `PT (Pacific Time)`.
`PT` isn't good enough, unfortunately.

When an update happens to the this file, the next step is to generate the
accompanying documentation. This takes the format of the following types of doc files:

```
sig-<sig-name>/README.md
wg-<working-group-name>/README.md
ug-<user-group-name>/README.md
committee-<committee-name>/README.md
sig-list.md
```

For example, if a contributor has updated `wg-serving`, the
following files will be generated:

```
wg-serving/README.md
wg-list.md
```

## How to use

To (re)build documentation for all the SIGs in a go environment, run:

```bash
make generate
```
or to run this inside a docker container:
```bash
make generate-dockerized
```

To build docs for one SIG, run one of these commands:

```bash
make WHAT=ug-onprem
make WHAT=wg-serving
```

where the `WHAT` var refers to the directory being built.

## Adding custom content

### README

If your SIG, WG, UG or Committee wishes to add custom content, you can do so by placing it within
the following code comments:

```markdown
<!-- BEGIN CUSTOM CONTENT -->

<!-- END CUSTOM CONTENT -->
```

Anything inside these code comments are saved by the generator and appended
to newly generated content. Updating any content outside this block, however,
will be overwritten the next time the generator runs.

An example might be:

```markdown
<!-- BEGIN CUSTOM CONTENT -->
## Upcoming SIG goals
- Do this
- Do that
<!-- END CUSTOM CONTENT -->
```

### OWNERS_ALIASES

Similarly, custom aliases can be added in the `OWNERS_ALIASES` file by placing
it within the following code comments:

```yaml
## BEGIN CUSTOM CONTENT

## END CUSTOM CONTENT
```