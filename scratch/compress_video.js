const ffmpegPath = require('@ffmpeg-installer/ffmpeg').path;
const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const fs = require('fs');

ffmpeg.setFfmpegPath(ffmpegPath);

const inputPath = path.join(__dirname, '..', 'images', 'video.mp4');
const outputPath = path.join(__dirname, '..', 'public', 'images', 'video_compressed.mp4');
const finalPath = path.join(__dirname, '..', 'public', 'images', 'video.mp4');
const rawPath = path.join(__dirname, '..', 'images', 'video.mp4');

console.log('Starting video compression...');
console.log('Input video path:', inputPath);

ffmpeg(inputPath)
  .outputOptions([
    '-c:v libx264',
    '-crf 28',
    '-preset fast',
    '-vf scale=1280:-2',
    '-an', // remove audio track since video is muted background hero video
    '-movflags +faststart'
  ])
  .on('start', (cmd) => {
    console.log('Spawned FFmpeg command:', cmd);
  })
  .on('progress', (progress) => {
    if (progress.percent) {
      console.log(`Processing: ${Math.round(progress.percent)}% done`);
    }
  })
  .on('end', () => {
    console.log('Compression finished successfully!');
    const initialSize = (fs.statSync(inputPath).size / (1024 * 1024)).toFixed(2);
    const compressedSize = (fs.statSync(outputPath).size / (1024 * 1024)).toFixed(2);
    console.log(`Original Size: ${initialSize} MB`);
    console.log(`Compressed Size: ${compressedSize} MB`);

    // Overwrite public/images/video.mp4 and images/video.mp4 with compressed version
    fs.copyFileSync(outputPath, finalPath);
    fs.copyFileSync(outputPath, rawPath);
    fs.unlinkSync(outputPath);
    console.log('Overwrote public/images/video.mp4 and images/video.mp4 with web-optimized video!');
  })
  .on('error', (err) => {
    console.error('Error during compression:', err);
  })
  .save(outputPath);
