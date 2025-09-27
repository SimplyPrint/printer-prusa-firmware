From 0e6a8d0f6c22a0cbfbc148b83bc051a65c37c1e3 Mon Sep 17 00:00:00 2001
From: Michal 'vorner' Vaner <vorner@vorner.cz>
Date: Fri, 3 Jan 2025 12:49:59 +0100
Subject: [PATCH] connect: Update backup files based on amount too

In addition to updating every 10s, make sure to also update every X
bytes transfered, so we don't lose as much and have higher chance to
show the preview sooner.

BFW-6428.
---
 src/transfers/transfer.cpp | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/src/transfers/transfer.cpp b/src/transfers/transfer.cpp
index 787feb97b..f61ad045e 100644
--- a/src/transfers/transfer.cpp
+++ b/src/transfers/transfer.cpp
@@ -236,9 +236,11 @@ void Transfer::init_download_order_if_needed() {
 
 void Transfer::update_backup(bool force) {
     const auto state = partial_file->get_state();
-    const auto crossed_size = !initial_part_done && state.get_valid_size() >= PlainGcodeDownloadOrder::MinimalFileSize /* This one is just a guess at "probably ready to print" */;
-    bool backup_outdated = last_backup_update_ms.has_value() == false || ticks_ms() - *last_backup_update_ms > BackupUpdateIntervalMs;
-    if (force == false && !backup_outdated && !crossed_size) {
+    const size_t size = state.get_valid_size();
+    const bool backup_outdated = last_backup_update_ms.has_value() == false || ticks_ms() - *last_backup_update_ms > BackupUpdateIntervalMs;
+    const bool did_cross_size = size - last_backup_update_bytes > BackupUpdateIntervalBytes;
+    if (force == false && !backup_outdated && !did_cross_size) {
+        log_debug(transfers, "Not updating backup file (%zu confirmed, %zu downloaded)", last_backup_update_bytes, size);
         return;
     }
 
@@ -251,13 +253,10 @@ void Transfer::update_backup(bool force) {
     if (Transfer::update_backup(backup_file.get(), partial_file->get_state()) == false) {
         log_error(transfers, "Failed to update backup file");
     } else {
-        log_info(transfers, "Backup file updated");
+        log_info(transfers, "Backup file updated at %zu", size);
     }
     last_backup_update_ms = ticks_ms();
-
-    if (crossed_size) {
-        initial_part_done = true;
-    }
+    last_backup_update_bytes = size;
 
     if (is_printable && !already_notified) {
         notify_created();
-- 
2.34.1

