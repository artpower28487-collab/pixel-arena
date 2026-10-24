PIXEL ARENA PUBLIC WEBSITE

Deploy the complete folder to HTTPS static hosting (for example Vercel). Keep supabase-config.js beside index.html. The supplied Supabase publishable key is intended for browser use; the database policies in supabase-setup.sql protect records.

Before launch, run supabase-setup.sql in the Supabase SQL Editor and create the private owner account. Full steps are in CONNECT-BOTH-SITES.txt.

Court booking requests are saved to Supabase as pending, and active offers are read from Supabase. The venue must still confirm availability. Cafe orders use WhatsApp. Court availability and automatic offer discounts are not implemented. UPI payments are not automatically verified.
