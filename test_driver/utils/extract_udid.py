def main():
  udid = ''
  with open('test_driver/utils/devices.txt') as f:
    udid = f.read().split()[-2]
  udid = udid.rstrip(')').lstrip('(')
  return udid

if __name__ == "__main__":
  main()
