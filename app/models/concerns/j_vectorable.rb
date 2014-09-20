module JVectorable
  JVECTOR_REGION_CODES = {
    "Anhui" => "CN-34",
    "Beijing" => "CN-11",
    "Chongqing" => "CN-50",
    "Fujian" => "CN-35",
    "Gansu" => "CN-62",
    "Guangdong" => "CN-44",
    "Guangxi" => "CN-45",
    "Guizhou" => "CN-52",
    "Hainan" => "CN-46",
    "Hebei" => "CN-13",
    "Heilongjiang" => "CN-23",
    "Henan" => "CN-41",
    "Hubei" => "CN-42",
    "Hunan" => "CN-43",
    "Inner Mongolia" => "CN-15",
    "Jiangsu" => "CN-32",
    "Jiangxi" => "CN-36",
    "Jilin" => "CN-22",
    "Liaoning" => "CN-21",
    "Ningxia" => "CN-64",
    "Qinghai" => "CN-63",
    "Shaanxi" => "CN-61",
    "Shandong" => "CN-37",
    "Shanghai" => "CN-31",
    "Shanxi" => "CN-14",
    "Sichuan" => "CN-51",
    "Tianjin" => "CN-12",
    "Xinjiang" => "CN-65",
    "Tibet" => "CN-54",
    "Yunnan" => "CN-53",
    "Zhejiang" => "CN-33"
  }

  def jvector_codes
    JVECTOR_REGION_CODES
  end

  def jvector_keys
    jvector_codes.keys
  end
end
