# tansei
Proof of Technology on the use Use of In-house Object Storage (IOS)

![social preview image](https://repository-images.githubusercontent.com/547824137/3f9ea998-36c9-476f-90be-e7940161cfed)

## Usage
### produce COPC files
```
ruby tansei.rb
```
### mount IOS on the server
To serve COPC file from IOS by mounting the bucket using `s3fs` and by serving them using `nginx`:
```
s3fs tansei tansei -o passwd_file=/home/pi/.passwd-s3fs,use_path_request_style,url=https://[the server]:8911,rw,allow_other,uid=$(id -u www-data),gid=$(id -g www-data)
```

## Software used
- `mc`
- `pdal`
- `zip`

## About social preview image
[Tansei-3](https://www.isas.jaxa.jp/en/missions/spacecraft/past/tansei-3.html) ((c) ISAS/JAXA)

