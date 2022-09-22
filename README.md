# Amplitude user deletion script

Part of the GDPR user deletion pipeline.

## Setup

A configuration file called `.config.sh` is required for the script to work.

A template [`.config.sh.dist`](.config.sh.dist) file is provided as an example.
It is a good idea to make a copy of it and fill in the missing fields:
- Your work email (for auditing purposes).
- API and secret keys for the appropriate projects.

  Those can be found in the [Projects section](https://analytics.amplitude.com/balena/settings/projects) of Amplitude settings, called `Stg - Core` (staging) and `Prod - Core` (production).

It should look something like the following
```sh
#!/usr/bin/env bash
REQUESTER_EMAIL="yourname@balena.io"

STAGING_API_KEY="stagingapikey"
STAGING_SECRET_KEY="stagingsecretkey"

PRODUCTION_API_KEY="productionapikey"
PRODUCTION_SECRET_KEY="productionsecretkey"
```

## Usage

---

**Warning**: this is a destructive operation.
Amplitude offers a grace period during which requests can be revoked but after that all data associated with the user will be purged from all Amplitude's systems.
You can read their current policy [here](https://developers.amplitude.com/docs/user-deletion#deletion-request).

---

The script is initiated by running
```sh
./user_deletion.sh <user_id>
```
where `user_id` is the username on balenaCloud platform.

## Example

### Output

A typical output of the script is the following:

```sh
➜ ./user_deletion.sh john_doe
Requesting to delete a user from Amplitude on behalf of 'yourname@balena.io'.
Please check the output below for sanity (at least some deletion jobs should be scheduled):
Delete user 'john_doe' on STAGING...
HTTP 400 - Bad request - User not found?
...request finished.
Delete user 'john_doe' on PRODUCTION...
HTTP 200 - Success - Looks all good!
[
   {
      "amplitude_ids" : [
         {
            "amplitude_id" : 12345,
            "requested_on_day" : "2021-01-01",
            "requester" : "yourname@balena.io"
         },
         {
            "amplitude_id" : 54321,
            "requested_on_day" : "2021-01-01",
            "requester" : "yourname@balena.io"
         }
      ],
      "app" : "000000",
      "day" : "2021-01-15",
      "status" : "staging"
   }
]
...request finished.
```

### Explanation

Requests to delete the user `john_doe` were made:

No such user was found in the staging project (a fairly typical case).

Two different Amplitude IDs (e.g. of different devices, eventually merged) were found in the production environment. They were scheduled for deletion on January 15th (the requests were supposedly sent on January 1st).

## Troubleshooting

Response bodies can be inspected by looking at `response_*.log` files for further details.
