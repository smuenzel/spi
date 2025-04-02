#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/bigarray.h>

/* CR smuenzel: need to figure out a way to include iobuf.h from core_unix.iobuf_unix */
enum iobuf_fields { iobuf_buf, iobuf_lo_min, iobuf_lo, iobuf_hi, iobuf_hi_max };

CAMLprim value spi_transfer_stub(value v_fd, value v_transfer_array)
{
  CAMLparam1(v_transfer_array);
  size_t number_of_transfers = Wosize_val(v_transfer_array);
  int fd = Int_val(v_fd);
  if(number_of_transfers == 0)
  {
    CAMLreturn(Val_int(0));
  }

  struct spi_ioc_transfer transfers[number_of_transfers] = {};

  for(size_t i = 0; i < number_of_transfers; i++)
  {
    value v_entry = Field(v_transfer_array, i);

    value v_tx_buf_opt = Field(v_entry, 0); 
    if(Is_some(v_tx_buf_opt))
    {
      value v_tx_buf = Some_val(v_tx_buf_opt);
      value v_tx_buf_bs = Field(v_tx_buf, iobuf_buf);
      ptrdiff_t tx_buf_start = Long_val(Field(v_tx_buf, iobuf_lo));
      transfers[i].tx_buf = 
        (typeof(transfers[i].tx_buf))
        ((uint8_t*)Caml_ba_data_val(v_tx_buf_bs) + tx_buf_start);
    }

    value v_rx_buf_opt = Field(v_entry, 1); 
    if(Is_some(v_rx_buf_opt))
    {
      value v_rx_buf = Some_val(v_rx_buf_opt);
      value v_rx_buf_bs = Field(v_rx_buf, iobuf_buf);
      ptrdiff_t rx_buf_start = Long_val(Field(v_rx_buf, iobuf_lo));
      transfers[i].rx_buf = 
        (typeof(transfers[i].rx_buf))
        ((uint8_t*)Caml_ba_data_val(v_rx_buf_bs) + rx_buf_start);
    }

    transfers[i].len = Long_val(Field(v_entry, 2));
    transfers[i].speed_hz = Long_val(Field(v_entry, 3));
    transfers[i].delay_usecs = Long_val(Field(v_entry, 4));
    transfers[i].bits_per_word = Long_val(Field(v_entry, 5));
    transfers[i].cs_change = Bool_val(Field(v_entry, 6));
    transfers[i].tx_nbits = Long_val(Field(v_entry, 7));
    transfers[i].rx_nbits = Long_val(Field(v_entry, 8));
    transfers[i].word_delay_usecs = Long_val(Field(v_entry, 9));
  }

  caml_enter_blocking_section();
  int status = ioctl(fd, SPI_IOC_MESSAGE(number_of_transfers), transfers);
  caml_leave_blocking_section();
  
  CAMLreturn(Val_int(status));

}
