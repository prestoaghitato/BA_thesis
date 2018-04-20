package IO;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import core.SequenceSet;

public class DataWriter {
	
	public void writeSequenceSetSPMF(String desDir, String desFile, SequenceSet seqSet)
	{

		File file = new File(desDir);
		file.mkdirs();
		
		try {
			FileWriter fw = new FileWriter(new File(desDir + "\\" + desFile));
			BufferedWriter bw = new BufferedWriter(fw);
			
			bw.write(seqSet.toStringSPMF());
			
			bw.close();
			fw.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	public void replace(String dirURL, String desURL, String[][] rm)
	{
		FileReader fr;
		BufferedReader br;
		
		FileWriter fw;
		BufferedWriter bw;
		
		StringBuffer sb;
		String text;
		
		String[] files = new File(dirURL).list();
		String zeile;
		
		for(String file: files)
		{
			sb = new StringBuffer();
			
			try {
				fr = new FileReader(new File(dirURL + "\\" + file));
				br = new BufferedReader(fr);
				
				while((zeile = br.readLine())!= null)
				{	
					zeile = zeile.replace("?", "");
					
					if(!zeile.contains("singel") && !zeile.contains("single") && !zeile.contains("nicht codierbar"))
					sb.append(zeile + "\n");
				}
				
				text = sb.toString();
				
				for(String[] rr: rm)
				{
					text = text.replace(rr[0],rr[1]);
				}
				
				br.close();
				fr.close();
				
				fw = new FileWriter(new File(desURL + "\\" + file));
				bw = new BufferedWriter(fw);
				
				bw.write(text);
				
				bw.close();
				fw.close();
				
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void writeFile(String desFile, String toWrite)
	{
		try {
			FileWriter fw = new FileWriter(new File(desFile));
			BufferedWriter bw = new BufferedWriter(fw);
			
			bw.write(toWrite);
			
			bw.close();
			fw.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
