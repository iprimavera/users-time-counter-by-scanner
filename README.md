# users time counter by scanner (Outdated)

> ⚠️ **This repository contains the base and original version of the project.**  
> It is **no longer maintained or updated**.

## New Version Available

The project is being entirely rewritten and improved in kotlin, with major optimizations and a cleaner modular architecture:

**-> New version in development:** [Work time scanner](https://github.com/iprimavera/Work-time-scanner.git)

## How to use the scanner

To run the scanner, use `./scanner.sh`

To see the calendar and users data, run `./display.sh`


The scanner is very simple. when executed, it automatically creates all the required files and starts listening for an ID (with the scanner).

When a new ID is read, the scanner asks for the user's full name and email address.

The scanner must be reset if the day has changed since its last reset (before first use of the day).

## Prerequisites for Sending Emails to Users

> **Note:** If you don’t want to send emails, enter `n` when the script prompts you or set each user’s value in `gecos.csv` to `n`.

1. **Generate an App Password**  
   You’ll need an application-specific password for the sender address. Follow this guide to create one:  
   [App Password Guide](https://itsupport.umd.edu/itsupport?id=kb_article_view&sysparm_article=KB0015112)

2. **Configure Your Sender Credentials**  
   - Open the script and locate the `email_sender` variable. Set it to your email address.  
   - Locate the `password` variable and paste in the app password you generated.

3. **Install Python 3**  
   Make sure `python3` is installed and available on your system.  
