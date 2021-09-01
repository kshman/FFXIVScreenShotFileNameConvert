using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VarConsole
{
	// 파판14 스크린샷 미쿡날짜를 한쿡날짜로 바꾸는것
	class FfxivFname
	{
		// 이미지 파일이 있는 곳
		static string ff14ss = @"My Games\FINAL FANTASY XIV - A Realm Reborn\screenshots";

		public static void Run(string[] args)
		{
			string folder;

			if (args.Length > 0)
				folder = args[0];
			else
			{
				string doc = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
				folder = Path.Combine(doc, ff14ss);
			}

			Console.WriteLine("FF14 스크린샷의 파일이름응 양놈에서 우리껄로 바꿔드립니다!");
			Console.WriteLine("디렉터리 위치: {0}", folder);
			
			if (!Directory.Exists(folder))
			{
				Console.WriteLine("위치가 존재하지 않아서 더이상 할 수 없습니다");
				return;
			}

			// 파일 목록 획득
			List<string> fnames = new List<string>();

			var di = new DirectoryInfo(folder);
			foreach (var fi in di.GetFiles())
			{
				if (fi.Name.StartsWith("ffxiv_"))
					fnames.Add(fi.Name);
			}

			// 파일 검사
			List<Fname> fns = new List<Fname>();
			int noymds = 0;

			foreach (var fs in fnames)
			{
				var fn = new Fname(fs);

				if (!fn.Ymd)
				{
					noymds++;
					fns.Add(fn);
				}
			}

			// 진행 묻기
			if (noymds==0)
			{
				Console.WriteLine("진행할 파일이 없어서 그만둡니다");
				return;
			}

			Console.WriteLine("진행할 파일 개수는 {0}개. 계속하려면 0을 입력하세요", noymds);
			if (!Console.ReadLine().StartsWith("0"))
			{
				Console.WriteLine("0이 아니므로 취소합니다");
				return;
			}

			// 진행
			foreach (var fn in fns)
			{
				if (fn.Ymd)
					continue;

				string final = fn.FinalString();

				Console.WriteLine("Y / {0} ← {1}", final, fn.Source);

				try
				{
					string on = Path.Combine(folder, fn.Source);
					string nn = Path.Combine(folder, final);
					File.Move(on, nn);
				}
				catch { }
			}

			// 끝
			Console.WriteLine("끝났습니다.");
		}

		class Fname
		{
			public int Year { get; private set; }
			public int Month { get; private set; }
			public int Day { get; private set; }
			public string Extend { get; private set; }

			public bool Ymd { get; private set; }

			public string Source { get; private set; }

			public Fname()
			{
			}

			public Fname(string fs)
			{
				ParseFname(fs);
			}

			public bool ParseFname(string fs)
			{
				Source = fs;

				if (fs.Length < 14)
					return false;

				var ls = fs.Substring(6, 8);
				Extend = fs.Substring(14);

				// 년도 테스트
				try
				{
					Year = int.Parse(ls.Substring(4, 4));
					// 지금은 2000년대라 2000이상이면 ㅇㅋ
					// 월이 20월은 없쟎아
					if (Year >= 2000)
					{
						// mdy
						Month = int.Parse(ls.Substring(0, 2));
						Day = int.Parse(ls.Substring(2, 2));
					}
					else
					{
						// ymd
						Year = int.Parse(ls.Substring(0, 4));
						Month = int.Parse(ls.Substring(4, 2));
						Day = int.Parse(ls.Substring(6, 2));
						Ymd = true;
					}
				}
				catch
				{
					return false;
				}


				return true;
			}

			public string FinalString()
			{
				StringBuilder sb = new StringBuilder();

				sb.Append("ffxiv_");
				sb.AppendFormat("{0:D4}{1:D2}{2:D2}", Year, Month, Day);
				sb.Append(Extend);

				return sb.ToString();
			}
		}
	}
}
