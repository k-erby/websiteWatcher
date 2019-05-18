# websiteWatcher

Just made to check if my prof modified her personal site to add new assignments
and stuff. If she's put up a new entry, it'll check the format and create a file
that's stored in `notebooks/`:
- if it's a pdf, program runs a subprocess call to download it (through wget)
- if it's html, program will parse the html and convert parsed text to a `.txt`.

## Usage

Idk, I guess you can change the URL to one you want and take out the
notebook stuff. You'd then run this:

'''
shards install   # you'll need myhtml

crystal run src/websiteWatcher.cr
'''

## Contributing

1. Fork it (<https://github.com/your-github-user/websiteWatcher/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
