# Testing the final configuration

1. From the compute source, ssh into the Azure VM:

```bash
ssh -i ~/.ssh/lza-oracle-single-instance  oracle@<PUBLIC_IP_ADDRESS>
```

1. Check the Oracle related environment variables:

```bash
env | grep -i oracle
```

1. Connect to the database:

```bash
sqlplus / as sysdba
show user
```

![Test image](media/test.jpg)

Congratulations!!! Now, you have a functional Oracle DB running on the Azure VM.
