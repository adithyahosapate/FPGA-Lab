`timescale 1ns / 1ps
module parking_system( 
  input clk,reset_n,
  input sensor_entrance, sensor_exit, 
  input pushbutton_0,input pushbutton_1,
  output[3:0] digit_out,
  output reg GREEN_LED,output reg RED_LED,output reg IDLE_LED
);

parameter IDLE = 3'b000, WAIT_PASSWORD = 3'b001, WRONG_PASS = 3'b010, RIGHT_PASS = 3'b011,STOP = 3'b100;
parameter WAIT_EXIT_PASSWORD = 3'b101, RIGHT_EXIT_PASS = 3'b111;
parameter pass1=4'b1100, pass2=4'b1001, pass3=4'b1010, pass4=4'b0101;  
parameter CAPACITY=4;
 

reg[2:0] current_state, next_state;
reg[31:0] counter_wait;
reg red_tmp,green_tmp,idle_temp;

reg[4:0] num_cars;
reg [3:0] password_temp;
reg button_old_0;
reg button_old_1;
initial button_old_0=0;
initial button_old_1=0;
reg [3:0] temp_counter;
reg [26:0] delay;
reg flag[0:3];
reg change_flag[0:3];
initial flag[0]=0;
initial flag[1]=0;
initial flag[2]=0;
initial flag[3]=0;
initial change_flag[0]=0;
initial change_flag[1]=0;
initial change_flag[2]=0;
initial change_flag[3]=0;

reg [3:0]counter[0:3];
reg [30:0]delays[0:3];
reg [30:0]show_delay;
initial num_cars=0;


always @(posedge clk)
begin
    current_state <= next_state;

    if(current_state==WAIT_PASSWORD || current_state==WAIT_EXIT_PASSWORD)
    begin
        if (pushbutton_0 == 1'b1 && button_old_0 == 0)
        begin
            password_temp<=password_temp*2;
            temp_counter<=temp_counter+1; //=
            button_old_0<=1;
        end
        else if (pushbutton_0 == 1'b0 && button_old_0 == 1)
        begin
          button_old_0<=0;
        end   
      
      
      if (pushbutton_1 == 1'b1 && button_old_1 == 0)
        begin
            password_temp<=password_temp*2+1; //=
            temp_counter<=temp_counter+1;
            button_old_1<=1;
        end
      else if (pushbutton_1 == 1'b0 && button_old_1 == 1)
        begin
          button_old_1<=0;
        end
        
    end
    
    
    case(current_state)
    IDLE: 
      begin
          temp_counter <= 3'b000;
          password_temp <= 4'b0000;
          if(sensor_entrance == 1 && num_cars < CAPACITY)
              next_state <= WAIT_PASSWORD;
          else if(sensor_exit == 1 && num_cars > 0)
              next_state <= WAIT_EXIT_PASSWORD;
          else
              next_state <= IDLE;
      end
    WAIT_PASSWORD: 
      begin
        if((temp_counter==4)&&((password_temp==pass1)||(password_temp==pass2)||(password_temp==pass3)||(password_temp==pass4)))
        begin
             if(password_temp==pass1)
                flag[0]<=1;
             else if(password_temp==pass2)
                flag[1]<=1;
             else if(password_temp==pass3)
                flag[2]<=1;
             else if(password_temp==pass4)
                flag[3]<=1;   
             next_state <= RIGHT_PASS;
             temp_counter<=0;
             password_temp<=4'b0000;
             num_cars<=num_cars+1;
        end
        else if((temp_counter==4)&&(password_temp!=pass1)&&(password_temp!=pass2)&&(password_temp!=pass3)&&(password_temp!=pass4))
        begin
            next_state <= IDLE;
            temp_counter<=0;
            password_temp<=4'b0000;
        end
        else
            next_state<=WAIT_PASSWORD;
      end

    WAIT_EXIT_PASSWORD: 
      begin
        if((temp_counter==4)&&((password_temp==pass1)||(password_temp==pass2)||(password_temp==pass3)||(password_temp==pass4)))
        begin
             
             if(password_temp==pass1)
             begin
                flag[0]<=0;
                change_flag[0]<=1;
             end   
             else if(password_temp==pass2)
             begin
                flag[1]<=0;
                change_flag[1]<=1;
             end   
             else if(password_temp==pass3)
             begin
                flag[2]<=0;
                change_flag[2]<=1;
             end   
             else if(password_temp==pass4)
             begin
                flag[3]<=0;
                change_flag[3]<=1;
             end      
             next_state <= RIGHT_EXIT_PASS;
             temp_counter<=0;
             password_temp<=4'b0000;
             num_cars<=num_cars-1;
        end
        else if((temp_counter==4)&&(password_temp!=pass1)&&(password_temp!=pass2)&&(password_temp!=pass3)&&(password_temp!=pass4))
        begin
            next_state <= IDLE;
            temp_counter<=0;
            password_temp<=4'b0000;
        end
        else
            next_state<=WAIT_EXIT_PASSWORD;
      end

    RIGHT_PASS: 
    begin
      delay <= delay+1;
      if(delay==27'b111100011110100001001000000) // 111100011110100001001000000 is 126829120 in decimal => 100 MHz freq => delay = 126829120/10^8 (so, it will stay in RIGHT_PASS for approx 1.26 sec)
      begin
          delay <= 27'b0;
          next_state <= IDLE;
      end
      else
        next_state<=RIGHT_PASS;
    end

    RIGHT_EXIT_PASS: 
    begin
      delay <= delay+1;
      if(delay==27'b111100011110100001001000000) // 111100011110100001001000000 is 126829120 in decimal => 100 MHz freq => delay = 126829120/10^8 (so, it will stay in RIGHT_PASS for approx 1.26 sec)
      begin
          delay <= 27'b0;
          next_state <= IDLE;
      end
      else
        next_state<=RIGHT_EXIT_PASS;
    end

    default: 
      next_state <= IDLE;
    endcase


    if(reset_n==1)
      next_state<=IDLE;
    case(current_state)
       IDLE: 
       begin
         idle_temp<=1'b1;
         red_tmp <= 1'b0;
         green_tmp <= 1'b0;
       end
       WAIT_PASSWORD: 
       begin
         idle_temp<=1'b0;
         red_tmp <= 1'b1;
         green_tmp <= 1'b1;
       end
       WAIT_EXIT_PASSWORD: 
       begin
         idle_temp<=1'b1;
         red_tmp <= 1'b1;
         green_tmp <= 1'b1;
       end
       RIGHT_EXIT_PASS: 
       begin
         idle_temp<=1'b1;
         red_tmp <= 1'b0;
         green_tmp <= 1'b1;
       end
       RIGHT_PASS: 
       begin
         idle_temp<=1'b0;
         red_tmp <= 1'b0;
         green_tmp <= 1'b1;
       end
       
    endcase
    RED_LED <=red_tmp;
    GREEN_LED <= green_tmp;
    IDLE_LED <= idle_temp;
    
    
    if(flag[0]==1)
    begin
      delays[0]<=delays[0]+1;
      if(delays[0]==29'b11111100011110100001001000000)
      begin
        delays[0]<=27'd0;
        counter[0]<=counter[0]+1;
      end
    end
    if(flag[1]==1)
    begin
      delays[1]<=delays[1]+1;
      if(delays[1]==29'b11111100011110100001001000000)
      begin
        delays[1]<=27'd0;
        counter[1]<=counter[1]+1;
      end
    end
    if(flag[2]==1)
    begin
      delays[2]<=delays[2]+1;
      if(delays[2]==29'b111100011110100001001000000)
      begin
        delays[2]<=27'd0;
        counter[2]<=counter[2]+1;
      end
    end
    if(flag[3]==1)
    begin
      delays[3]<=delays[3]+1;
      if(delays[3]==29'b111100011110100001001000000)
      begin
        delays[3]<=27'd0;
        counter[3]<=counter[3]+1;
      end
    end 
    
    if(change_flag[0]==1)
    begin
      if(show_delay==29'b111100011110100001001000000)
      begin
        digit_out<=num_cars;
        show_delay<=0;
        change_flag[0]<=0;
        delays[0]<=0;
        counter[0]<=0;
      end  
      else
        digit_out<=(counter[0]/5);
        show_delay<=show_delay+1;      
    end

    else if(change_flag[1]==1)
    begin
      if(show_delay==29'b111100011110100001001000000)
      begin
        digit_out<=num_cars;
        show_delay<=0;
        change_flag[1]<=0;
        delays[1]<=0;
        counter[1]<=0;
      end  
      else
        digit_out<=(counter[1]/5);
        show_delay<=show_delay+1;      
    end  

    else if(change_flag[2]==1)
    begin
      if(show_delay==29'b111100011110100001001000000)
      begin
        digit_out<=num_cars;
        show_delay<=0;
        change_flag[2]<=0;
        delays[2]<=0;
        counter[2]<=0;
      end  
      else
        digit_out<=(counter[2]/5);
        show_delay<=show_delay+1;      
    end  

    else if(change_flag[3]==1)
    begin
      if(show_delay==29'b111100011110100001001000000)
      begin
        digit_out<=num_cars;
        show_delay<=0;
        change_flag[3]<=0;
        delays[3]<=0;
        counter[3]<=0;
      end  
      else
        digit_out<=counter[3]/5;
        show_delay<=show_delay+1;      
    end    
    else
        digit_out<=num_cars;
      
end


endmodule
