// Singleton 
class CSingleton {  
private:  
	CSingleton() {}  
	static CSingleton *m_pInstance;  
	class CGarbo {  
		//����Ψһ��������������������ɾ��CSingleton��ʵ��  
		public:  
			~CGarbo() {  
				if(CSingleton::m_pInstance)  
					delete CSingleton::m_pInstance;  
			}  
	}; 
	static CGarbo Garbo;  //����һ����̬��Ա�������������ʱ��ϵͳ���Լ���������������������  
public:  
	static CSingleton * GetInstance() {  
		if(m_pInstance == NULL)  //�ƶ��Ƿ��һ�ε���  
			m_pInstance = new CSingleton();  
		return m_pInstance;  
	} 
};
