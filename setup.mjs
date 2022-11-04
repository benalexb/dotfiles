#!/usr/bin/env zx

const symlink = (file, target) => {
  // Check if file and target exist
  // Only create symlink if file and target both exist.
  // Should we fail gracefully or exit the script with an error?
}

const backup = (file) => {
  // Check if the file to be backed up actually exists
  // Only back it up if it actually exists
  // Should we fail gracefully or exit the script with an error?
}

const runTasks = async () => {
  const isSpin = !!process.env.SPIN
  try {
    console.log(`isSpin: ${isSpin}`)
    process.exit(0)
  } catch (error) {
    console.error(error)
    process.exit(1)
  }
}

runTasks()
