Git does not like empty directories, yet the assets folder is assumed to exist by the producer_push task.
This should solve that problem when deploying from git.