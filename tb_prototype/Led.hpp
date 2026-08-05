class Led
{
  private:
    int numeroPin;

  public:
    Led(int pin);
    ~Led();
    void allumer();
    void eteindre();
};
