From 19071ef4f5cf33a4ae4e8b4933b232fdb338150c Mon Sep 17 00:00:00 2001
From: Michal 'vorner' Vaner <vorner@vorner.cz>
Date: Fri, 26 Jul 2024 10:39:58 +0200
Subject: [PATCH] Transfer: Fix access after free
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Under some circumstances (plain-gcode file of the correct size), we
could reach a situation where we do have the whole file downloaded, but
the download itself is capable of providing some more data, therefore
claims „Continue“. We would then first finalize the file and then
continue the attempts to download it further, resulting in access to a
null pointer.

We could probably take more care of setting the range header more
thoroughly in such situation, but the server can send more data anyway,
so better protect us this way.

BFW-5859.
---
 src/transfers/transfer.cpp | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/src/transfers/transfer.cpp b/src/transfers/transfer.cpp
index 8d22bae69..89936796f 100644
--- a/src/transfers/transfer.cpp
+++ b/src/transfers/transfer.cpp
@@ -366,6 +366,13 @@ Transfer::State Transfer::step(bool is_printing) {
                     break;
                 case Transfer::Action::Finished:
                     done(State::Finished, Monitor::Outcome::Finished);
+                    // With the plain gcodes where we download out of order, it
+                    // may happen that we already have the whole file, but the
+                    // download would still be able to provide some more data
+                    // and would say Continue. Fix that situation up here
+                    // (especially because we don't want to touch the now
+                    // thrown away partial file).
+                    step_result = DownloadStep::Finished;
                     break;
                 }
             }
-- 
2.34.1

