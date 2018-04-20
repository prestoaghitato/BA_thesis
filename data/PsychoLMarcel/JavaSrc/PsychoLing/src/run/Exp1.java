package run;

import spmf.CM_SPAM_Runner;

public class Exp1 {
	
	public void run()
	{
		
			
		String input 	= "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\DatenSPMF\\dataSPMF.txt";
		String output 	= "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\SequenceMiningResults\\output.txt";		
		String log		= "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\SequenceMiningResults\\log.txt";		

		double th = 1;
		int maxLength  = 5;
		
		
//		new File(log_Map.get(SPMF_SPAM)[0]).mkdirs();	
		CM_SPAM_Runner.run(input, output, log, th, maxLength);
	}

}
