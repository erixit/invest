# SD Card Cloning and Expansion Guide

If you need to upgrade your Raspberry Pi's SD card to a larger size while preserving all installed Docker containers, databases, and configurations, follow this guide.

## Step 1: Create an Image of the Current Card

You will need a computer (Windows, Mac, or Linux) with an SD card reader.

1.  **Power down** your Raspberry Pi and remove the small SD card.
2.  Insert it into your computer.
3.  Use a tool to "Read" the card into a single `.img` file on your computer's hard drive.
    *   **Windows:** Use **Win32DiskImager**. Select the SD card drive letter, choose a filename (e.g., `backup.img`), and click **Read**.
    *   **Mac/Linux:** You can use the command line `dd` tool or the "Disks" utility (Linux) / "Disk Utility" (Mac) to create a disk image.

## Step 2: Write to the New (Bigger) Card

1.  Remove the old card and insert the **new, larger SD card** into your computer.
2.  Use **Raspberry Pi Imager**, **BalenaEtcher**, or **Win32DiskImager**.
3.  Select the `.img` file you just created as the source.
4.  Select the new SD card as the destination.
5.  **Write/Flash** it.

## Step 3: Expand Filesystem (Crucial)

When you boot the Pi with the new card, it will still *think* it is the size of the old card because the partition table was cloned exactly. You must expand it to use the full capacity.

1.  Boot the Pi with the new card.
2.  Open a terminal.
3.  Run the configuration tool:
    ```bash
    sudo raspi-config
    ```
4.  Go to **Advanced Options** > **Expand Filesystem**.
5.  Select it, finish, and **Reboot**.

After the reboot, run `df -h` to verify that the full capacity of your new card is available. All your Docker containers and data will be preserved.
