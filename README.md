# S3 *FOLDER* point in time restore

Restores an s3 bucket folder to the version at provided time.

It also creates an original folder backup with a `.original` suffix.

> Based on [angeloc/s3-pit-restore](https://github.com/angeloc/s3-pit-restore).

## Requirements

- Bucket should have *versioning* enabled.
- AWS credentials file, provided by `AWS_FOLDER`. By default `$HOME/.aws`.

## Build

```
make
```

Or `make build`, will create a local container image.

## Run

```
TIME="03-15-2021 20:00:00 +0" BUCKET="bucket_name" PREFIX="folder_path" make restore
```

### Workflow

1. It verifies there is no previous *restore* backup.
2. Restores folder at provided point back in time, within new folder copy suffixed with `.restored`.
3. Verifies there is no previous *original* backup.
4. Renames *original* folder with `.original` suffix.
5. Renames *restored* folder with original name.

## Common errors

### dates compare offset

```
if version_date > pit_end_date or version_date < pit_start_date:
TypeError: can't compare offset-naive and offset-aware datetimes
```

Date format is invalid.

Ensure that it follows this format `"03-15-2020 20:00:00 UTC"`.

