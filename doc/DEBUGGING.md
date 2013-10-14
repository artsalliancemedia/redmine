## Log Files

We have two primary log files we can use for debugging, these are:

* Thin Server Log
* Rails Debugging Log

These can be found under `/var/log` on the system. They should be on a rotation to save space, I would request all log files just to make sure.

## Production Database Backups

Probably the best way of getting to the bottom of any data issues is to back up the database and have them send it over to us. They should use the `pg_dump` utility to generate a SQL dump that we can import at our end for debugging locally.